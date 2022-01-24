//
//  PhoneContact.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-18.
//

import Foundation
import Contacts

class PhoneContact: NSObject {

    var name: String?
//    var avatarData: Data?
    var phoneNumber: [String] = [String]()
    var phoneNumberNoPrefix: [String] = [String]()

    var email: [String] = [String]()
    var isSelected: Bool = false
    var isInvited = false
    var id = UUID().uuidString

    init(contact: CNContact) {
        name        = contact.givenName + " " + contact.familyName
//        avatarData  = contact.thumbnailImageData
        
        let prefixes = ContactsViewModel.shared.getCountryPrefixCodes()

        for phone in contact.phoneNumbers {
           
            phoneNumber.append(phone.value.stringValue)
            let countryCode = phone.value.value(forKey: "countryCode") as? String
            var digits = phone.value.value(forKey: "digits") as? String
            
            if digits?.first == "+" {
                digits?.removeFirst()
            }
            
            if let countryCode = countryCode, let prefix = prefixes[countryCode.uppercased()], var digits = digits {
                if digits.hasPrefix(prefix) {
                    digits.removeFirst(prefix.count)
                    phoneNumberNoPrefix.append(digits)
                }
            }
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
        
      
    }

    override init() {
        super.init()
    }
}
