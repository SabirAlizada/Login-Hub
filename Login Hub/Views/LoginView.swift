//
//  LoginView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI

struct LoginView: View {
    let viewModel: SocialLoginViewModel
    
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .top) {
                VStack {
                    LoginHeaderView()
                    Spacer()
                }
                BottomSheet {
                    AuthCardView(viewModel: viewModel)
                }
            }
        }
    }
}
