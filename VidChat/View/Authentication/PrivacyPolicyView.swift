//
//  PrivacyPolicyView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-29.
//


import SwiftUI

struct PrivacyPolicyView: View {
    
    private let textSections = [
        
        //Section 1
        TextSection(header: "Introduction", subSections: [
            TextSubSection(title: "", paragraph: "VidChat respects your privacy. This Privacy Policy explains how VidChat collects, uses, discloses, and safeguards your personal information when you access VidChat. Please read this Privacy Policy carefully. In order to use VidChat, you must agree with this Privacy Policy. VidChat reserves the right to make changes to this Privacy Policy at any time. You will become aware of changes by updating the “Last Updated” date of this Privacy Policy. All changes to the Privacy Policy will be effective upon posting. VidChat encourages you to review this Privacy Policy frequently to remain informed of updates. Your continued use of the mobile app after any Privacy Policy alterations will signify that you accept any and all changes made to the Privacy Policy after such changes are posted.")
        ]),
        
        //Section 2
        TextSection(header: "Collection Of Your Information", subSections: [
            
            TextSubSection(title: "", paragraph: "We may collect information about you in a variety of ways. The information we may collect on the mobile application includes:"),
            
            TextSubSection(title: "Personal Information", paragraph: "Personally identifiable information, such as your name, email address, and friends that you voluntarily give to VidChat when you register or when you choose to participate in various activities on VidChat. You are under no obligation to provide us with personal information, however your refusal to do so may prevent you from using certain features of VidChat."),
            
            TextSubSection(title: "Derivative Data", paragraph: "Information our servers automatically collect when you access VidChat.org, such as your IP address, your browser type, your operating system and your access times. If you are using our mobile application, this information may also include your device name and type, your operating system, and other interactions with the application and other users via server log files, as well as any other information you choose to provide."),
            
            TextSubSection(title: "Mobile Device Data", paragraph: "Device information, such as your mobile device ID, model, and manufacturer, if you access the site from a mobile device."),
            
            TextSubSection(title: "Data From Contests, Giveaways, and Surveys", paragraph: "Personal and other information you may provide when entering contests or giveaways and/or responding to surveys."),
            
            TextSubSection(title: "Mobile Application Information", paragraph: "If you connect using our mobile application:\n\nMobile Device Access. We may request access or permission to certain features from your mobile device, including your mobile device’s reminders and other features. If you wish to change our access or permissions, you may do so in your device’s settings. \n\nMobile Device Data. We may collect device information (such as your mobile device ID, model and manufacturer), operating system, version information and IP address. \n\nPush Notifications. We may request to send you push notifications regarding your account or the Application. If you wish to opt-out from receiving these types of communications, you may turn them off in your device’s settings."),
            
        ]),
        
        //Section 3
        TextSection(header: "Use Of Your Information", subSections: [
            TextSubSection(title: "", paragraph: "Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Site or our mobile application to:\n\n-Administer sweepstakes, promotions, and contests\n-Assist law enforcement and respond to subpoena.\n-Compile anonymous statistical data and analysis for use internally or with third parties.\n-Create and manage your account.\n-Email you regarding your account.\n-Enable user-to-user communications.\n-Increase the efficiency and operation of the Site and our mobile application.\n-Monitor and analyze usage and trends to improve your experience with the Site and our mobile application.\n-Notify you of updates to the Site and our mobile applications.\n-Perform other business activities as needed.\n-Prevent fraudulent transactions, monitor against theft, and protect against criminal activity.\n-Request feedback and contact you about your use of the Site and our mobile application.\n-Resolve disputes and troubleshoot problems.\n-Respond to product and customer service requests.\n-Send you a newsletter.")
        ]),
        
        //Section 4
        TextSection(header: "Disclosure of Your Information", subSections: [
            
            TextSubSection(title: "", paragraph: "We may share information we have collected about you in certain situations. Your information may be disclosed as follows:"),
            
            TextSubSection(title: "By Law or to Protect Rights", paragraph: "If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others, we may share your information as permitted or required by any applicable law, rule, or regulation. This includes exchanging information with other entities for fraud protection and credit risk reduction."),
            
            TextSubSection(title: "Third-Party Service Providers", paragraph: "We may share your information with third parties that perform services for us or on our behalf, including payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance."),
            
            TextSubSection(title: "Marketing Communications", paragraph: "With your consent, or with an opportunity for you to withdraw consent, we may share your information with third parties for marketing purposes, as permitted by law. Interactions with Other Users If you interact with other users of the Site and our mobile application, those users may see your name, profile photo, and descriptions of your activity, including any posts that you may have uploaded to our services."),
            
            TextSubSection(title: "Other Third Parties", paragraph: "We may share your information with advertisers and investors for the purpose of conducting general business analysis. We may also share your information with such third parties for marketing purposes, as permitted by law."),
            
            TextSubSection(title: "Sale or Bankruptcy", paragraph: "If we reorganize or sell all or a portion of our assets, undergo a merger, or are acquired by another entity, we may transfer your information to the successor entity. If we go out of business or enter bankruptcy, your information would be an asset transferred or acquired by a third party. You acknowledge that such transfers may occur and that the transferee may decline honor commitments we made in this Privacy Policy. We are not responsible for the actions of third parties with whom you share personal or sensitive data, and we have no authority to manage or control third-party solicitations. If you no longer wish to receive correspondence, emails or other communications from third parties, you are responsible for contacting the third party directly."),
            
        ]),
        
        //Section 5
        TextSection(header: "Security of Your Information", subSections: [
            
            TextSubSection(title: "", paragraph: "We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse. Any information disclosed online is vulnerable to interception and misuse by unauthorized parties. Therefore, we cannot guarantee complete security if you provide personal information."),
            
        ]),
        
        //Section 6
        TextSection(header: "Policy For Children", subSections: [
            TextSubSection(title: "", paragraph: "We do not knowingly solicit information from or market to children under the age of 13. If you become aware of any data we have collected from children under age 13, please contact us using the contact information provided below.")
        ]),
        
        //Section 7
        TextSection(header: "Options Regarding Your Information", subSections: [
            TextSubSection(title: "", paragraph: "You may at any time review or change the information in your account or terminate your account by: Logging into your account settings and updating your account Contacting us using the contact information provided below Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases. However, some information may be retained in our files to prevent fraud, troubleshoot problems, assist with any investigations, enforce our Terms of Use and/or comply with legal requirements.")
        ]),
        
        //Section 8
        TextSection(header: "Contact Us", subSections: [
            TextSubSection(title: "", paragraph: "If you have questions or comments about these Terms and Conditions, please contact the VidChat Administrator at: Seb@vidchat.org")
        ]),
    ]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ScrollView {
                
                HStack {
                    
                    Text("Date last modified: Dec 29, 2021.")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.vertical)
                    
                    Spacer()
                }
                
                ForEach(Array(textSections.enumerated()), id: \.1.header) { i, textSection in
                    
                    TextSectionView(textSection: textSection).padding(.vertical)
                }
                
                Spacer()
            }
            
        }.padding(.horizontal, 20)
            .navigationTitle("Privacy Policy")
    }
}




