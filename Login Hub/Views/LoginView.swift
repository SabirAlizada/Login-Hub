//
//  LoginView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                LoginHeaderView()
                Spacer()
            }
            BottomSheet(content: AuthCardView())
        }
    }
}

#Preview {
    LoginView()
}
