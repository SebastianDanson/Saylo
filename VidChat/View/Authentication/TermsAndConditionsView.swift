//
//  TermsAndConditionsView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-29.
//

import SwiftUI

struct TextSection {
    let header: String
    let subSections: [TextSubSection]
}

struct TextSubSection {
    let title: String
    let paragraph: String
}

struct TermsAndConditionsView: View {
    
    private let textSections = [
        
        //Section 1
        TextSection(header: "Section 1: Introduction", subSections: [
            TextSubSection(title: "", paragraph: "Thank you for choosing VidChat. VidChat is an app that allows you to send video and text messages to your friends and family. VidChat refers to the VidChat mobile app and website. The VidChat Administrator consists of the individual listed in Section 10 of these Terms and Conditions. The VidChat Administrator may update or amend these Terms and Conditions from time to time. By accessing or using any service provided by, or affiliated with VidChat, you are entering into a binding contract with the VidChat Administrator. Please read these terms of use before using VidChat. If you do not agree with the terms of use, you may not use or access VidChat. You are not permitted to access VidChat if your VidChat account has been terminated by the VidChat Administrator.")
        ]),
        
        //Section 2
        TextSection(header: "Section 2: Using Our Service", subSections: [
            TextSubSection(title: "Account Termination", paragraph: "The VidChat Administrator reserves the right to terminate any account that violates these Terms and Conditions. By registering an account, VidChat grants you limited, revocable permission to use and access its platform. This access will remain in effect until terminated by you or VidChat.")
        ]),
        
        //Section 3
        TextSection(header: "Section 3: Account and Account Security", subSections: [
            TextSubSection(title: "", paragraph: "To access VidChat, you are required to register an account, by providing an email, and a name. When registering an account, you must use your legal name, or one that you frequently use in everyday life, provide accurate information about yourself, create only one account and keep your password private. You are responsible for all the information associated with, and uploaded to your account. You are also responsible for maintaining the security of your account. If your account is breached, you are required to contact VidChat Administrator immediately. The unauthorized licensing, selling or transfer of your account is prohibited.")
        ]),
        
        //Section 4
        TextSection(header: "Section 4: Content", subSections: [
            TextSubSection(title: "", paragraph: "VidChat is not responsible for, and does not endorse any content uploaded. All suggestions, feedback or ideas that you give to VidChat administration are entirely voluntary, and may be used to improve or modify VidChat functions.")
        ]),
        
        //Section 5
        TextSection(header: "Section 5: User Guidelines", subSections: [
            
            TextSubSection(title: "", paragraph: "When using or accessing VidChat, you must respect the rights and privacy of other users. We encourage users to report violations of these terms and conditions and improper use of VidChat. Violations of the following terms and conditions can result in the termination of your account."),
            
            TextSubSection(title: "A. Harassment, Bullying and Violence", paragraph: "You may not post content or make comments that are bullying, marginalizing, harassing or threatening in nature. The promotion of hate is forbidden."),
            
            TextSubSection(title: "B. Confidential Information", paragraph: "You may not share the confidential and personal information of other users."),
            
            TextSubSection(title: "C. Sexually Explicit Media", paragraph: "You may not post or threaten to post any sexually explicit material or media"),
            
            TextSubSection(title: "D. User Integrity", paragraph: "You may not assume any identity other than your own. You may not use any name other than your legal name or your commonly used name."),
            
            TextSubSection(title: "E. Illegal Content", paragraph: "You may not post any illegal content, nor facilitate any illegal acts."),
            
            TextSubSection(title: "F. Viruses", paragraph: "You may not use VidChat services to send software viruses, worms, or anything else that might interfere with the normal use of a computer or digital device."),
            
            TextSubSection(title: "G. VidChat Interactions", paragraph: "You may not attempt to break the VidChat website/app, or try to modify our platform in any way."),
            
            TextSubSection(title: "H. Data Collection", paragraph: "You may not use VidChat to access data for any commercial purposes, without express consent and approval from VidChat Administrator."),
            
        ]),
        
        //Section 6
        TextSection(header: "Section 6: Warranty Disclaimer", subSections: [
            TextSubSection(title: "", paragraph: "EXCEPT AS OTHERWISE EXPRESSLY PROVIDED IN THIS AGREEMENT, NEITHER PARTY MAKES ANY WARRANTY WITH RESPECT TO ANY TECHNOLOGY, GOODS, SERVICES, RIGHTS OR OTHER SUBJECT MATTER OF THIS AGREEMENT AND HEREBY DISCLAIMS WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT WITH RESPECT TO ANY AND ALL OF THE FOREGOING.")
        ]),
        
        //Section 7
        TextSection(header: "Section 7: Links To Third-Parties and Other Websites", subSections: [
            TextSubSection(title: "", paragraph: "Our mobile application may contain links to third-party websites and applications of interest, including advertisements and external services, that are not affiliated with us. Once you have used these links to leave the Site or our mobile application, any information you provide to these third parties is not covered by this Privacy Policy, and we cannot guarantee the safety and privacy of your information. Before visiting and providing any information to any third-party websites, you should inform yourself of the privacy policies and practices of the third party responsible for that website, and should take those steps necessary to, in your discretion, protect the privacy of your information. We are not responsible for the content or privacy and security practices and policies of any third parties, including other sites, services or applications that may be linked to or from the Site or our mobile application.")
        ]),
        
        //Section 8
        TextSection(header: "Section 8: Intellectual Property Rights", subSections: [
            TextSubSection(title: "", paragraph: "The VidChat Administrator may terminate account for violation of intellectual property rights or other proprietary rights.")
        ]),
        
        //Section 9
        TextSection(header: "Section 9: Changes", subSections: [
            TextSubSection(title: "", paragraph: "The VidChat Administrator may change these Terms and Conditions periodically, to adapt to changes to the law, regulatory policies, technology, and other changes. It is the responsibility of users to stay informed about them. By continuing use of VidChat, you agree to abide by the amended Terms and Conditions. It is thus important to review these Terms and Conditions frequently.")
        ]),
        
        //Section 10
        TextSection(header: "Section 10: Contact Us", subSections: [
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
    }
}

struct TextSectionView: View {
    
    let textSection: TextSection
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text(textSection.header).font(.system(size: 22, weight: .medium)).padding(.vertical, 6)
            
            ForEach(Array(textSection.subSections.enumerated()), id: \.1.paragraph) { i, subSection in
                
                if !subSection.title.isEmpty {
                    Text(subSection.title).font(.system(size: 18, weight: .bold))
                }
                
                if !subSection.paragraph.isEmpty {
                    Text(subSection.paragraph).font(.system(size: 16, weight: .regular))
                }
            }
        }
    }
}

