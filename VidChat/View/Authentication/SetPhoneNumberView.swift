//
//  SetPhoneNumberView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import SwiftUI
import CoreTelephony

struct CountryInfo {
    let dialCode: String
    let countryCode: String
}

struct SetPhoneNumberView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    
    @State private var phoneNumber = ""
    @State private var showInvalidPhoneNumber = false
    @State private var showError = false
    @State private var countryCode = ""
    @State private var showCountryList = false
    @State private var countryInitials = ""
    @State private var showVerifyPhoneNumber = false

    var body: some View {
        
        let invalidPhoneNumberAlert = Alert(
            title: Text("Invalid mobile number"),
            message: Text("Please add a valid mobile number"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        
        VStack {
          
            //email field
            
            VStack(spacing: 24) {
                
                VStack(alignment: .center, spacing: 4) {
                    
                    Text("What's your mobile \nnumber?")
                        .font(.system(size: 24, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.top, TOP_PADDING + 8)
                    
                    
                }.padding(.bottom, 16)
                
                
                //Username field
                
                VStack(spacing: -2) {
                    
                    HStack {
                        
                        Button {
                            showCountryList = true
                        } label: {
                            Text(countryInitials + " +" + countryCode)
                                .foregroundColor(.mainBlue)
                        }
                        
                        
                        Rectangle()
                            .frame(width: 1, height: 22)
                            .foregroundColor(.lightGray)
                            .padding(.bottom, 2)
                        
                        TextField("Phone number", text: $phoneNumber)
                            .foregroundColor(.systemBlack)
                            .frame(height: 35)
                            .keyboardType(.numberPad)
                        
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.lightGray), alignment: .bottom)
                    .padding(.top, 2)
                    .padding(.bottom)
                    .padding(.horizontal)
                    
                    
                    
                    //            NavigationLink(destination: SetProfileImageView(), isActive: $nameEntered) { EmptyView() }
                    
                    HStack {
                        Text("We'll send you an SMS verification code.")
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .padding(.leading, 14)
                    
                }.padding(.horizontal, 32)
                
                
            }
            Button(action: {
                
                //set phone number
                if (countryCode == "1" && phoneNumber.trimmingCharacters(in: .decimalDigits.inverted).count == 10) || (countryCode != "1" && ("+" + countryCode + phoneNumber).isValidPhoneNumber()) {
                    viewModel.setPhoneNumber(phoneNumber: phoneNumber.trimmingCharacters(in: .decimalDigits.inverted), countryCode: countryCode)
                } else {
                    showInvalidPhoneNumber = true
                }
                
            }, label: {
                
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 92, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 6 ? 0.5 : 1)
            })
                .disabled(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 6)
                .padding(.vertical, 28)
                .alert(isPresented: $showInvalidPhoneNumber) {
                    invalidPhoneNumberAlert
                }
            
            
            Spacer()
            
        }
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Text("Skip")
                        .foregroundColor(Color(.systemGray3))
                        .fontWeight(.medium)
                }
            }
          
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showCountryList, content: {
            NavigationView {
                CountryCodeViewController(countryInitials: $countryInitials, dialCode: $countryCode)
                    .navigationTitle("Country Codes")
            }
        })
        .onAppear {
            let countryInfo = getCountryCode()
            self.countryCode = countryInfo.dialCode
            self.countryInitials = countryInfo.countryCode
            
        }
        
    }
    
    func getCountryCode() -> CountryInfo {
        guard let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, let countryCode = carrier.isoCountryCode else { return CountryInfo(dialCode: "1", countryCode: "") }
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryCode.uppercased()] ?? String("1")
        return CountryInfo(dialCode: countryDialingCode, countryCode: countryCode.uppercased())
    }
}


struct Config {
    init() {}
    static var localIdentifier: Locale!
}



struct SectionedTextField: View {
    @State private var numberOfCells: Int = 8
    @State private var currentlySelectedCell = 0
    @State private var text = ""
    var body: some View {
        HStack {
            CustomTextField2(text: $text)
        }
    }
}


struct CustomTextField2: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String

        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }

//        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            let currentText = textField.text ?? ""
//
//            guard let stringRange = Range(range, in: currentText) else { return false }
//
//            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//
//            if updatedText.count <= 1 {
//                self.currentlySelectedCell += 1
//            } else if currentText.count == 0 {
//                self.currentlySelectedCell -= 1
//            }
//
//            return updatedText.count <= 1
//        }
        
      
    }

    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextField2>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.defaultTextAttributes.updateValue(36.0, forKey: NSAttributedString.Key.kern)
        return textField
    }

    func makeCoordinator() -> CustomTextField2.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField2>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}



