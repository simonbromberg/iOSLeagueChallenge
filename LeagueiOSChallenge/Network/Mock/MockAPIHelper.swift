//
//  MockAPIHelper.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-12.
//

import UIKit

class MockAPIHelper: APIService {
  var loginState: LoginState?

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func currentLoginState() -> LoginState? {
    loginState
  }

  func logIn(username: String, password: String) async throws {
    loginState = .user
  }

  func logOut() {
    loginState = nil
  }

  func logInAsGuest() async throws {
    loginState = .guest
  }

  func getUsers() async throws -> [UserResponse] {
    guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else {
      throw MockAPIError.missingFixture
    }

    let data = try Data(contentsOf: url)
    return try decoder.decode([UserResponse].self, from: data)
  }

  func getPosts() async throws -> [PostResponse] {
    guard let url = Bundle.main.url(forResource: "posts", withExtension: "json") else {
      throw MockAPIError.missingFixture
    }

    let data = try Data(contentsOf: url)
    return try decoder.decode([PostResponse].self, from: data)
  }

  func loadImageData(_ urlString: String) async throws -> Data {
    UIImage(systemName: "figure.wave")!.pngData()!
  }


  enum MockAPIError: Error {
    case missingFixture
  }
}
