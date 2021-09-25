//
//  Extensions.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
