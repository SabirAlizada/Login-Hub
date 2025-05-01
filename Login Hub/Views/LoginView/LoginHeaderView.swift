//
//  LoginHeaderView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 23.03.25.
//

import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            BackgroundView()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 5) {
                Image("universityLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 80)
                    .padding(.top, 5)

                Text("Get started now")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 32)
                
                Text("Log in or register to access courses, events, and more!")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 12)
                
                Spacer()
                
            }
            .padding(.leading, 24)
        }
    }
}
