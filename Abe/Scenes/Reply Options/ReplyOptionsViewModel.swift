
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift
import Contacts

enum Visibility: String {
    case all
    case facebook
    case contacts
}

extension CNContact {
    
    static func findContacts() -> [CNContact] {
        let store = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactThumbnailImageDataKey,
                           CNContactImageDataAvailableKey,
                           CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        
        var contacts = [CNContact]()
        
        do{
            try store.enumerateContacts(with: fetchRequest, usingBlock: {
                ( contact, stop) -> Void in
                // TODO: Guard required values dont add items that are null
                // Check for Mobile numbers, could be more than one.
                var mobileNumbers = [CNPhoneNumber]()
                var emailIds = [NSString]()
                
                for phoneNumber in contact.phoneNumbers {
                    mobileNumbers.append(phoneNumber.value)
                }
                for emailId in contact.emailAddresses {
                    emailIds.append(emailId.value)
                }
                // Only add Contacts with Mobile numbers!
                if (!mobileNumbers.isEmpty || !emailIds.isEmpty) {
                    contacts.append(contact)
                } else {
                    print("\(contact.givenName) does not have Mobile number listed!")
                }
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return contacts
    }
    
}

class ContactsStore {
    private let store = CNContactStore()
    
    func isAuthorized() -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
                self.store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                    if authorized {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                    
                    if let error = error {
                        observer.onError(error)
                    }
                })
            } else {
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func userContacts() -> Observable<[Contact]> {
        return Observable.create { observer in
            let contacts = self.fetchContacts()
            observer.onNext(contacts)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func fetchContacts() -> [Contact] {
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactThumbnailImageDataKey,
                           CNContactImageDataAvailableKey,
                           CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        
        var contacts = [Contact]()
        
        do{
            try store.enumerateContacts(with: fetchRequest, usingBlock: {
                (cnContact, stop) -> Void in
                let allNumbers = cnContact.phoneNumbers.map { $0.value.stringValue }
                let contact = Contact(id: cnContact.identifier,
                                      first: cnContact.givenName,
                                      last: cnContact.familyName,
                                      numbers: allNumbers)
                contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return contacts
    }
    
}

struct SavedReplyInput {
    let body: String
    let prompt: Prompt
}

struct ReplyOptionsViewModel {
    
    struct Input {
        let createTrigger: Driver<Void>
        let visibilitySelected: Driver<Visibility>
        let cancelTrigger: Driver<Void>
    }
    
    struct Output {
        let visibilityOptions: Driver<[Visibility]>
        let didCreateReply: Observable<Void>
        let savedContacts: Driver<Void>
        let loading: Driver<Bool>
        let errors: Driver<Error>
    }
    
    private let realm: RealmRepresentable
    private let router: ReplyOptionsRoutingLogic
    private let prompt: Prompt
    private let user: UserInfo
    private let contactsStore: ContactsStore
    private let savedReplyInput: SavedReplyInput
    
    var promptTitle: String { return prompt.title }
    
    init(realm: RealmRepresentable,
         prompt: Prompt,
         savedReplyInput: SavedReplyInput,
         router: ReplyOptionsRoutingLogic) {
        self.prompt = prompt
        self.realm = realm
        self.contactsStore = ContactsStore()
        self.savedReplyInput = savedReplyInput
        self.router = router
        guard let userInfo = UserDefaultsManager.userInfo() else { fatalError() }
        self.user = userInfo
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let loading = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        let options: [Visibility] = [.all, .facebook, .contacts]
        let visbilityOptions = Driver.of(options)
        
        let user = self.realm
            .query(User.self, with: User.currentUserPredicate, sortDescriptors: [])
            .map { $0.first! }
            .asDriverOnErrorJustComplete()
   
        let selectedVisibility = input.visibilitySelected
        
        let shouldAskForContacts = selectedVisibility
            .filter { $0 == Visibility.contacts }
            .withLatestFrom(user)
            .map { $0.contacts.count }
            .filter { $0 < 1 }
        
        let userContacts = shouldAskForContacts
            .mapToVoid()
            .flatMapLatest { _ in
                return self.contactsStore.isAuthorized()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .map{ $0 }
            .flatMap { _ in
                self.contactsStore.userContacts().asDriverOnErrorJustComplete()
            }
    
        let savedContacts = userContacts
            .withLatestFrom(user) { (contacts, user) in
                return self.realm.update {
                    contacts.forEach { user.contacts.append($0) }
                }
                .trackError(errorTracker)
                .trackActivity(activityIndicator)
            }
            .mapToVoid()
        
        let currentPrompt = Driver.of(prompt)
        let savedReplyInput = Driver.of(self.savedReplyInput)
        
        let reply =
            Driver.combineLatest(currentPrompt,
                                 user,
                                 savedReplyInput,
                                 selectedVisibility) { (prompt, user, replyInput, visibility) -> PromptReply in
            return PromptReply(userId: user.id,
                               userName: user.name,
                               promptId: prompt.id,
                               body: replyInput.body,
                               visibility: visibility.rawValue)
        }
        
        let didCreateReply = input.createTrigger
            .asObservable()
            .withLatestFrom(reply)
            .flatMapLatest { (reply) -> Observable<Void> in
                return self.realm.update {
                        self.prompt.replies.insert(reply, at: 0)
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .do(onNext: router.toPromptDetail)
        
        return Output(visibilityOptions: visbilityOptions,
                      didCreateReply: didCreateReply,
                      savedContacts: savedContacts,
                      loading: loading,
                      errors: errors)
    }

}
