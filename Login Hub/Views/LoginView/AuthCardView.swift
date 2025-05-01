//
//  LoginCardView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 23.03.25.
//

import SwiftUI

struct AuthCardView: View {
    
    @State private var selectedTab: AuthTab = .login
    
    private enum AuthTab: String, CaseIterable, Identifiable {
        case login = "Log in"
        case signup = "Sign up"
        var id: Self { self }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Picker(selection: $selectedTab, label: Text("")) {
                ForEach(AuthTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .frame(height: 44)
            .scaleEffect(x: 1, y: 1, anchor: .center)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Switch content based on selected tab
            Group {
                if selectedTab == .login {
                    LoginContentView()
                        .transition(.move(edge: .leading))
                } else {
                    SignupContentView()
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: selectedTab)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedCornerRectangle(radius: 25, corners: [.topLeft, .topRight])
                .fill(Color.white)
        )
        .compositingGroup()
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

struct BottomSheet<Content: View>: View {
    let content: Content
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                content
                    .padding(.bottom, keyboardHeight)
                    .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    // Calculates keyboard height relative to safe area
                    let height = frame.height - geometry.safeAreaInsets.bottom
                    keyboardHeight = height > 0 ? height : 0
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

