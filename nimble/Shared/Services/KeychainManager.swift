//
//  KeychainManager.swift
//  Nimble
//
//  Created by darius vallejo on 11/10/23.
//

import Foundation
import Security

protocol KeychainRecordable {
    func saveTokens(_ accessToken: String, refreshToken: String)
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
}

class KeychainManager: KeychainRecordable {
    static let shared = KeychainManager()

    private let service = "NimbleService"
    private let accessTokenKey = "AccessToken"
    private let refreshTokenKey = "RefreshToken"

    func saveTokens(_ accessToken: String, refreshToken: String) {
        saveToKeychain(value: accessToken, forKey: accessTokenKey)
        saveToKeychain(value: refreshToken, forKey: refreshTokenKey)
    }

    func getAccessToken() -> String? {
        return getFromKeychain(forKey: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return getFromKeychain(forKey: refreshTokenKey)
    }

    private func saveToKeychain(value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]

            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)

            if status != errSecSuccess {
                print("Error saving to Keychain: \(status)")
            }
        }
    }

    private func getFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            print("Error retrieving from Keychain: \(status)")
            return nil
        }
    }
}
