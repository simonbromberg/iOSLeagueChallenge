//
//  APIHelper.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-10.
//

import Foundation

enum LoginState {
  case user
  case guest
}

protocol APIService {
  func currentLoginState() -> LoginState?
  func logIn(username: String, password: String) async throws
  func logInAsGuest() async throws
  func logOut()
  func getUsers() async throws -> [UserResponse]
  func getPosts() async throws -> [PostResponse]
  func loadImageData(_ urlString: String) async throws -> Data
}

struct APIHelper: APIService {
  let baseURL: String

  init(baseURL: String = "https://engineering.league.dev/challenge/api/") {
    self.baseURL = baseURL
  }

  enum Endpoint: String {
    case login
    case users
    case posts
    case albums
    case photos
  }

  private func url(for endpoint: Endpoint) throws -> URL {
    guard let url = URL(string: baseURL + endpoint.rawValue) else {
      throw NetworkingError.invalidURL
    }
    return url
  }

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  // MARK: - Authentication

  func currentLoginState() -> LoginState? {
    if CredentialStore.apiKey != nil {
      CredentialStore.isUser ? .user : .guest
    } else {
      nil
    }
  }

  func logIn(username: String, password: String) async throws {
    let url = try url(for: .login)

    guard !username.isEmpty, !password.isEmpty else {
      throw NetworkingError.missingCredentials
    }

    guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
      throw NetworkingError.credentialsEncodingFailure
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)

    let response = try decoder.decode(LoginResponse.self, from: data)

    CredentialStore.apiKey = response.apiKey
    CredentialStore.isUser = true
  }

  func logInAsGuest() async throws {
    let url = try url(for: .login)

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("No Auth", forHTTPHeaderField: "Authorzation")

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try decoder.decode(LoginResponse.self, from: data)
    CredentialStore.apiKey = response.apiKey
  }

  func logOut() {
    CredentialStore.apiKey = nil
    CredentialStore.isUser = false
  }

  // MARK: - Posts

  func getPosts() async throws -> [PostResponse] {
    let data = try await getData(endpoint: .posts)
    return try decoder.decode([PostResponse].self, from: data)
  }

  // MARK: - Users

  func getUsers() async throws -> [UserResponse] {
    let data = try await getData(endpoint: .users)
    return try decoder.decode([UserResponse].self, from: data)
  }

  // MARK: - Images

  func loadImageData(_ urlString: String) async throws -> Data {
    if let cachedImageData = ImageCache.fetchImageData(urlString) {
      return cachedImageData
    }

    guard let url = URL(string: urlString) else {
      throw NetworkingError.invalidURL
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    ImageCache.saveImageData(imageData: data, to: urlString)
    return data
  }

  // MARK: - Helper

  func getData(endpoint: Endpoint) async throws -> Data {
    guard let apiKey = CredentialStore.apiKey else {
      throw NetworkingError.missingAPIKey
    }

    var request = try URLRequest(url: url(for: endpoint))
    request.httpMethod = "GET"
    request.addValue(apiKey, forHTTPHeaderField: "x-access-token")

    let (data, _) = try await URLSession.shared.data(for: request)

    return data
  }

  // MARK: - Error

  enum NetworkingError: Error {
    case invalidURL
    case missingCredentials
    case credentialsEncodingFailure
    case missingAPIKey
  }
}
