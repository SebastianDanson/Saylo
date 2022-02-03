//
//  CountryCodeViewController.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//


import UIKit
import SwiftUI

struct CountryCodeViewController: UIViewControllerRepresentable {

    @Binding var countryInitials: String
    @Binding var dialCode: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<CountryCodeViewController>) -> DialCountriesController {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = context.coordinator
//        controller.show(vc: self)

        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: DialCountriesController, context: UIViewControllerRepresentableContext<CountryCodeViewController>) {}

    class Coordinator: NSObject, DialCountriesControllerDelegate {
        
        func didSelected(with country: Country) {
            if var dialCode = country.dialCode {
                dialCode.removeFirst()
                self.parent.dialCode = dialCode
                self.parent.countryInitials = country.code
            }
        }
        
        
        let parent: CountryCodeViewController
        
        init(_ parent: CountryCodeViewController) {
            self.parent = parent
        }
        
    }
}
