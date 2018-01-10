
import Foundation
import Contacts
import RxSwift
import PhoneNumberKit

class ContactsStore {
    
    private let store = CNContactStore()
    private let phoneNumberKit = PhoneNumberKit()
    
    func isAuthorized() -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
                observer.onNext(false)
                observer.onCompleted()
            } else {
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func requestAccess() -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            self.store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                if authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                }
                
                if let error = error {
                    observer.onError(error)
                }
            })
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
                let allNumbers = cnContact.phoneNumbers.map { $0.value.stringValue.digits }
                let contact = Contact(id: UUID().uuidString,
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

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
