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
    var email: [String] = [String]()
    var isSelected: Bool = false
    var isInvited = false
    var id = UUID().uuidString

    init(contact: CNContact) {
        name        = contact.givenName + " " + contact.familyName
//        avatarData  = contact.thumbnailImageData
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }

    override init() {
        super.init()
    }
}
