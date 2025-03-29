//
//  LoginCardView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 23.03.25.
//

import SwiftUI

struct AuthCardView: View {

    @State private var selectedTab: AuthTab = .login

    enum AuthTab {
        case login
        case signup
    }

    var body: some View {
        VStack(spacing: 20) {
            Picker("", selection: $selectedTab) {
                Text("Log in").tag(AuthTab.login)
                Text("Sign up").tag(AuthTab.signup)
            }
            .pickerStyle(.segmented)
            .frame(height: 44)
            .scaleEffect(x: 1, y: 1.2, anchor: .center)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Switch content based on selected tab
            switch selectedTab {
            case .login:
                LoginContentView()
            case .signup:
                SignupContentView()
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedCornerRectangle(radius: 25, corners: [.topLeft, .topRight])
                .fill(Color.white)
        )
    }
}

struct RoundedCornerRectangle: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
