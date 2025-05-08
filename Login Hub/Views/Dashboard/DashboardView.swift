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
    @EnvironmentObject var viewModel: SocialLoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            Group {
                if let url = URL(string: userProfile.avatarURL ?? "") {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    // Default profile image for Apple Sign In
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(userProfile.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(userProfile.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Signed in with \(userProfile.provider.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Logout Button
            Button(action: {
                viewModel.logout()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
