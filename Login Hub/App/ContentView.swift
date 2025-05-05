//
//  ContentView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI

struct ContentView: View {
    let viewModel: SocialLoginViewModel
    
    var body: some View {
        LoginView(viewModel: viewModel)
    }
}
