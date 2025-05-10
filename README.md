# Login Hub

**Login Hub** is a SwiftUI-based sample application that replicates a university login flow. It demonstrates email/password authentication, user registration, and social sign-in via Facebook, Google, and Apple, all built with best practices in mind.

## 📋 Features

* **Email/Password Login & Registration**: Secure user sign‑in and sign‑up flows with form validation (regex checks, minimum age).
* **Social Authentication**:

  * Sign in with **Facebook**
  * Sign in with **Google**
  * Sign in with **Apple**
* **Architecture**: MVVM pattern using **Combine** for reactive state management.
* **SwiftUI**: Full UI built in SwiftUI, leveraging custom views, view modifiers, and animations.
* **SOLID Principles**: Code organized for single responsibility, dependency inversion, and easy testability.
* **Input Validation**: Centralized `InputValidator` for names, emails, passwords, and phone numbers.
* **Keyboard Handling**: Seamless form scrolling and adaptive layout above the keyboard.
* **Unit Tests**: XCTest cases covering ViewModel logic and social login flows.

## 🛠️ Tech Stack

* **Language**: Swift 5
* **Frameworks**: SwiftUI, Combine, Firebase Auth, FBSDKLoginKit, GoogleSignIn, AuthenticationServices
* **Architecture**: MVVM (Model-View-ViewModel)
* **Dependency Management**: Swift Package Manager (SPM)
* **Testing**: XCTest, Combine async streams

## 🚀 Getting Started

### Prerequisites

* Xcode 14.0 or later
* iOS 15.0 or later
* CocoaPods/Carthage (optional, if using alternative package managers)
* A Firebase project configured with Authentication enabled
* Facebook App ID and Google OAuth client set up in your Info.plist

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/login-hub.git
   cd login-hub
   ```
2. **Install dependencies**

   * If using SPM, open `Login Hub.xcodeproj` and resolve packages.
3. **Configure your environment**

   * Add your `GoogleService-Info.plist` for Firebase.
   * Add `FacebookAppID`, `FacebookDisplayName`, and URL schemes to Info.plist.
   * Configure Sign in with Apple capabilities.
4. **Run the app**

   * Select the `Login Hub` scheme and run on a simulator or device.

## 📂 Project Structure

```
Login Hub/
├── AppDelegate.swift       # Facebook SDK setup
├── Login_HubApp.swift      # App entry, Firebase configuration
├── Views/                  # SwiftUI view components
│   ├── LoginView.swift
│   ├── SignupView.swift
│   └── Common/             # Reusable UI components (Fields, Buttons)
├── ViewModels/             # MVVM ViewModels
│   ├── SocialLoginViewModel.swift
│   └── LoginViewModel.swift
├── Services/               # Authentication services
│   ├── AuthService.swift   # Firebase and Social providers
│   └── Providers/          # Facebook, Google, Apple providers
├── Models/                 # Data models
│   └── SocialUserProfile.swift
├── Utilities/              # Validators, modifiers, extensions
│   └── InputValidator.swift
├── Resources/              # Assets, Info.plist, Config files
└── Tests/                  # Unit tests (XCTest)
```

## 🤝 Contributing

Contributions are welcome! Feel free to:

* Report bugs or open issues
* Submit pull requests for enhancements
* Propose new features or improvements

Please follow the existing code style and include tests for any new functionality.


*This README was generated on the request of the project maintainers to provide a clear overview and installation guide.*
