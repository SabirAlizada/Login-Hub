import Foundation
import CryptoKit

// MARK: - Nonce Generation

// Utility for generating a secure random nonce and its SHA256 hash for Apple Sign-In
struct AppleSignInNonce {
    // Generates a random alphanumeric nonce string.
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        let charset: [Character] = Array(characters)
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random) % charset.count])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    // MARK: - Hashing
    
    // Computes SHA256 hash of the input string.
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
