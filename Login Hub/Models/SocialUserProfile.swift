//
//  SocialUserModel.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation

enum SocialProvider: String, CaseIterable, Codable {
    case facebook, google, apple
}

struct SocialUserProfile: Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let provider: SocialProvider
}
