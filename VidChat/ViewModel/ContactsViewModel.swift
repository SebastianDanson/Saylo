//
//  ContactsViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-18.
//

import Foundation
import Contacts
import ContactsUI

struct ContactsViewModel {
    
    
    static let shared = ContactsViewModel()
    private init() {}
    
    func getContacts() -> [CNContact] { //  ContactsFilter is Enum find it below

        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]

        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }

        var results: [CNContact] = []

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
    
    
    func requestAccessToContacts(completion: @escaping((Bool) -> Void)) {
        CNContactStore().requestAccess(for: .contacts) { (access, error) in
          print("Access: \(access)")
            completion(access)
        }
    }
    
    func getPhoneContacts() -> [PhoneContact] {

        let contacts = getContacts() // here calling the getContacts methods
        var phoneContacts = [PhoneContact]()
        
        for contact in contacts {
            phoneContacts.append(PhoneContact(contact: contact))
        }
        
        return phoneContacts 
    }
   
}
