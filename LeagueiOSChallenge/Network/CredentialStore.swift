//
//  CredentialStore.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-11.
//

import Foundation

/// placeholder, should be replaced with proper keychain service
struct CredentialStore {
  static var apiKey: String? {
    get {
      UserDefaults.standard.string(forKey: "apiKey")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "apiKey")
    }
  }

  static var isUser: Bool {
    get {
      UserDefaults.standard.bool(forKey: "isUser")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "isUser")
    }
  }
}
