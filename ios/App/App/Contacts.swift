import Foundation
import Capacitor
import Contacts

@objc(Contacts)
public class Contacts : CAPPlugin {
    // MARK: - Properties
    private let contactStore = CNContactStore()
    private let keysToFetch = [CNContactGivenNameKey,
                       CNContactFamilyNameKey,
                       CNContactPhoneNumbersKey,
                       CNContactEmailAddressesKey] as [CNKeyDescriptor]
    private var contacts = [Any]()
    
    @objc func getAll(_ call: CAPPluginCall) {
        requestContactAccess { result in
            switch result {
            case .success(_):
                //self.fetchAllContacts(call)
                self.getFilteredContacts(call)
            case .failure(let error):
                call.reject(error.localizedDescription)
            }
        }
    }
    
    @objc func getFilteredContacts(_ call: CAPPluginCall) {
        let firstName = call.options["firstName"] as? String ?? ""
        do {
            let predicate = CNContact.predicateForContacts(matchingName: firstName)
            let data = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            for contact in data {
                addToListOfContacts(contact: contact)
            }
            print(contacts)
            call.success([
                "contacts": contacts
            ])
        } catch {
            call.reject("Error fetching contacts: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func fetchAllContacts(_ call: CAPPluginCall) {
        do {
        let request = CNContactFetchRequest(keysToFetch: self.keysToFetch)
        try self.contactStore.enumerateContacts(with: request) { contact, stop in
            self.addToListOfContacts(contact: contact)
        }
        print(contacts)
        call.success([
            "contacts": contacts
        ])
        } catch {
            call.reject("Error fetching contacts \(error)")
        }
    }
    
    private func addToListOfContacts(contact: CNContact) {
        contacts.append([
            "firstName": contact.givenName,
            "lastName": contact.familyName,
            "phoneNumbers": [contact.phoneNumbers.first?.value.stringValue],
            "emailAddresses": [contact.emailAddresses.first?.value]
        ])
    }
    
    private func requestContactAccess(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        contactStore.requestAccess(for: .contacts) { granted, error in
            if granted {
                completionHandler(.success(true))
            }
            if let error = error {
                completionHandler(.failure(error))
            }
        }
    }
    
    private func getAllMocked() -> [Any] {
        return [
            [
                "firstName": "Elton",
                "lastName": "Json",
                "phoneNumbers": ["2135551111"],
                "emailAddresses": ["elton@eltonjohn.com"],
            ],
            [
                "firstName": "Freddie",
                "lastName": "Mercury",
                "phoneNumbers": [],
                "emailAddresses": [],
            ],
        ]
    }
}
