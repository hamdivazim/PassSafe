//
//  PrivacyNoticeView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 31/12/2022.
//

import SwiftUI

struct PrivacyNoticeView: View {
    @Binding var showPopup: Bool
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "hand.raised.fill")
                    .resizable()
                    .frame(width: 100, height: 120)
                    .foregroundColor(.blue)
                
                Text("Privacy Notice")
                    .font(.largeTitle.bold())
            }
            .padding()
            
            Text("Your passwords are securely encrypted and stored safely in the cloud. No one (not even me!) can access your passwords. I also do not collect any data from my users, so you can rest easy knowing your passwords are in a safe and secure place where nobody, except you, can access :)")
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                showPopup = false
            } label: {
                Text("Done")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(.blue)
                    }
                    .padding(.vertical)
            }
        }
        .padding()
    }
}

struct PrivacyNoticeView_Previews: PreviewProvider {
    @State static var showPopup = true
    
    static var previews: some View {
        PrivacyNoticeView(showPopup: $showPopup)
    }
}
