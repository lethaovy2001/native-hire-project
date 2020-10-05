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
    
    // MARK: - Plugin Methods
    @objc func getAll(_ call: CAPPluginCall) {
        contactStore.requestAccess(for: .contacts) { granted, error in
            if granted {
                do {
                    let request = CNContactFetchRequest(keysToFetch: self.keysToFetch)
                    try self.contactStore.enumerateContacts(with: request) { contact, stop in
                        self.addToListOfContacts(contact: contact)
                    }
                    call.success([
                        "contacts": self.contacts
                    ])
                } catch {
                    call.reject("Error fetching contacts \(error)")
                }
            }
            if let error = error {
                call.reject("Access Denied: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func getFilteredContacts(_ call: CAPPluginCall) {
        contactStore.requestAccess(for: .contacts) { granted, error in
            if granted {
                let predicate = self.getPredicate(from: call)
                do {
                    let data = try self.contactStore.unifiedContacts(matching: predicate,
                                                                     keysToFetch: self.keysToFetch)
                    for contact in data {
                        self.addToListOfContacts(contact: contact)
                    }
                    call.success([
                        "contacts": self.contacts
                    ])
                } catch {
                    call.reject("Error fetching contacts: \(error)")
                }
            }
            if let error = error {
                call.reject("Access Denied: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func addToListOfContacts(contact: CNContact) {
        var phoneNumbers = [String]()
        var emailAddresses = [String]()
        
        for phoneNumber in contact.phoneNumbers {
            phoneNumbers.append(phoneNumber.value.stringValue)
        }
        for email in contact.emailAddresses {
            emailAddresses.append(email.value as String)
        }
        
        contacts.append([
            "firstName": contact.givenName,
            "lastName": contact.familyName,
            "phoneNumbers": phoneNumbers,
            "emailAddresses": emailAddresses
        ])
    }
    
    private func getPredicate(from call: CAPPluginCall) -> NSPredicate {
        var predicate = CNContact.predicateForContacts(matchingName: "")
        if let firstName = call.options["firstName"] as? String {
            predicate = CNContact.predicateForContacts(matchingName: firstName)
        }
        if let phoneNumber = call.options["phoneNumber"] as? CNPhoneNumber {
            predicate = CNContact.predicateForContacts(matching: phoneNumber)
        }
        if let emailAddress = call.options["emailAddress"] as? String {
            predicate = CNContact.predicateForContacts(matchingEmailAddress: emailAddress)
        }
        return predicate
    }
}
