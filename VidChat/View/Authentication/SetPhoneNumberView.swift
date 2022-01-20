//
//  SetPhoneNumberView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import SwiftUI
import CoreTelephony

struct SetPhoneNumberView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    
    @State private var username = ""
    @State private var nameEntered = false
    @State private var showInvalidUsername = false
    @State private var showError = false
    @State private var isLoading = false
    @State private var phoneNumber = ""
    @State private var countryCode = ""
    @State private var showCountryList = true
    
    var body: some View {
        
        let invalidUsernameAlert = Alert(
            title: Text("Your username must be under 50 characters"),
            message: nil,
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        let usernameTakenAlert = Alert(
            title: Text("This username is already taken"),
            message: Text("Please enter a different username"),
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
                    
                    Text("Set your username")
                        .font(.system(size: 30, weight: .medium))
                    
                    
                    Text("Your username should be at least 4\ncharacters")
                        .font(.system(size: 18, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.mainGray)
                        .padding(.vertical, 4)
                    
                }.padding(.bottom, 6)
                
                
                //Username field
                
                HStack {
                    
                    TextField("Country\nCode", text: $countryCode)
                        .foregroundColor(.systemBlack)
                        .frame(height: 35)
                        .keyboardType(.phonePad)
                    
                    
                    TextField("Phone number", text: $phoneNumber)
                        .foregroundColor(.systemBlack)
                        .frame(height: 35)
                        .keyboardType(.phonePad)
                    

                }
                    .padding(.top, 2)
                    .padding(.bottom)
                    .padding(.horizontal)
                
            }.padding(.horizontal, 32)
            
            
            NavigationLink(destination: SetProfileImageView(), isActive: $nameEntered) { EmptyView() }
            
            
            Button(action: {
                
                if username.count >= 50  {
                    showInvalidUsername = true
                } else if !username.isEmpty {
                    
                    isLoading = true
                                        
                    
                    viewModel.setUsername(username: username.trimmingCharacters(in: .whitespacesAndNewlines)) { alreadyTaken in
                        
                        if alreadyTaken {
                            showInvalidUsername = false
                            showError = true
                        } else {
                            nameEntered = true
                        }
                        
                        isLoading = false
                    }
                }
                
            }, label: {
                
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 92, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(username.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 ? 0.5 : 1)
            })
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).count < 4)
                .padding(.vertical, 20)
                .alert(isPresented: $showError) {
                    
                    if showInvalidUsername {
                        return invalidUsernameAlert
                    } else {
                        return usernameTakenAlert
                    }
                }
            
            if isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 50, height: 50)
                
            }
            
            
            Spacer()
            
        }.navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showCountryList, content: {
                CountryCodeViewController()
            })
            .onAppear {
                print(getCountryCode(), "CODE")
            }
    }
    
    func getCountryCode() -> String {
        guard let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, let countryCode = carrier.isoCountryCode else { return "" }
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryCode.uppercased()] ?? String("1")
        return countryDialingCode
    }
}

extension String {
    func isValidPhoneNumber() -> Bool {
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"

        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
}



import UIKit

public protocol DialCountriesControllerDelegate: AnyObject {
    
    func didSelected(with country: Country)
}

public class DialCountriesController: UITableViewController, UISearchResultsUpdating {
    
    private let fetcher = CountriesFetcher()
    private var countryList = [Country]()
    private var countryFilter = [Country]()
    public weak var delegate: DialCountriesControllerDelegate?
    private let searchController = UISearchController(searchResultsController: nil)
    private var adapter: CountriesAdapter!
    
    public init(locale: Locale) {
        Config.localIdentifier = locale
        super.init(nibName: nil, bundle: nil)
    }
    
    public func show(vc: UIViewController) {
        let nav = UINavigationController(rootViewController: self)
        vc.present(nav, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        countryList = fetcher.fetch()
        countryFilter = countryList
        
        setupTableView()
        setupSearchController()
        
    }
    
    private func setupTableView() {
        adapter = CountriesAdapter(items: countryFilter, delegate: self)
        self.tableView.delegate = adapter
        self.tableView.dataSource = adapter
    }
    
    private func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.titleView = self.searchController.searchBar
        definesPresentationContext = true
        
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            countryFilter = countryList.filter { country in
                return country.name.lowercased().contains(searchText.lowercased()) || (country.dialCode?.contains(searchText.toEnglishNumber()) == true) || country.code.lowercased().contains(searchText.lowercased())
            }
            
            
        } else {
            countryFilter = countryList
        }
        adapter.update(items: countryFilter)
        tableView.reloadData()
    }
}

extension DialCountriesController: CountriesAdapterDelegate {
    
    func didSelected(with country: Country) {
        self.delegate?.didSelected(with: country)
        searchController.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
}

protocol CountriesAdapterDelegate: AnyObject {
    func didSelected(with country: Country)
}

class CountriesAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    var items: [Country]
    weak var delegate: CountriesAdapterDelegate?
    
    init(items: [Country], delegate: CountriesAdapterDelegate) {
        self.items = items
        self.delegate = delegate
    }
    
    func update(items: [Country]) {
        self.items = items
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "\(indexPath.section)")
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.dialCode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        self.delegate?.didSelected(with: item)
    }
}



struct Config {
    init() {}
   static var localIdentifier: Locale!
}

import Foundation

//final class BundleLoader {
//
//    static func getBundle() -> Bundle {
//        guard let url = Bundle.main.url(forResource: "DialCountries", withExtension: "bundle") else {
//            fatalError("bundle not found")
//        }
//
//        return Bundle(url: url)!
//
//    }
//}

extension String {
    
    func toEnglishNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        guard let result = numberFormatter.number(from: self) else {
            
            return self
        }
        return result.stringValue
    }
}


public struct Country: Decodable {
    public var flag: String {
        
        return code
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    public let code: String
    public var name: String {
        Config.localIdentifier?.localizedString(forRegionCode: code) ?? ""
    }
    
    public var title: String {
        
        String(format: "%@ %@", self.flag, self.name)
    }
    public let dialCode: String?
    
    public static func getCurrentCountry() -> Country? {
        let locale: NSLocale = NSLocale.current as NSLocale
        let currentCode: String? = locale.countryCode
        return CountriesFetcher().fetch().first(where: { $0.code ==  currentCode})
    }
}
