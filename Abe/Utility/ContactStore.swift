
import Foundation
import Contacts
import RxSwift

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
