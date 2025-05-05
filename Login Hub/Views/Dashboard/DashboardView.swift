//
//  DashboardView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import SwiftUI

struct DashboardView: View {
    let userProfile: SocialUserProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if let url = URL(string: userProfile.avatarURL ?? "") {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            }
            Text(userProfile.name)
            Text(userProfile.email)
            // Add your university app components here
            
            Button("Log Out") {
                // Handle logout logic
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}
