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
    static let mainBlue = Color(red: 15/255, green: 188/255, blue: 249/255)
    static let lightGray = Color(red: 0.67, green: 0.67, blue: 0.67)
    static let iconGray = Color(red: 153/255, green: 153/255, blue: 153/255)
}
