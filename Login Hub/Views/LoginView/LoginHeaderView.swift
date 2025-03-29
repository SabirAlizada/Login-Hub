//
//  LoginHeaderView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 23.03.25.
//

import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            VStack(spacing: 5) {
                HStack() {
                    Image("universityLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 80)
                        .padding(.top, 10)
                    Spacer()
                }
                Text("Get started now")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Log in or register to access courses, events, and more!")
                    .multilineTextAlignment(.leading)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                
                Spacer()
                
            }
            .padding(.leading, 24)
        }
    }
}
