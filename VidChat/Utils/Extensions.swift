//
//  Extensions.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import UIKit
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let mainGreen = Color(red: 0, green: 206/255, blue: 201/255)
    static let mainBlue = Color(red: 116/255, green: 185/255, blue: 255/255)
}
