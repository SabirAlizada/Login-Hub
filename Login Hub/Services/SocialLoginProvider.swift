//
//  SocialLoginProvider.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation
import Combine

// Protocol for all social login providers (Facebook, Google, Apple)
protocol SocialLoginProvider {
    var loginPublisher: PassthroughSubject<SocialUserProfile, Error> { get }
    
    func login()
    
    func logout()
}
