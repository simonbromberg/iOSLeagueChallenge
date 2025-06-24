//
//  PostsViewModel.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-11.
//

import UIKit
import SwiftUI

class PostsViewModel {
  private let apiService: APIService

  init(apiService: APIService) {
    self.apiService = apiService
  }

  var userPosts = [UserPost]()

  func fetchPosts() async throws {
    async let posts = apiService.getPosts()
    async let users = apiService.getUsers()

    var usersById = [Int: UserResponse]()
    try await users.forEach {
      usersById[$0.id] = $0
    }

    try await userPosts = posts.map {
      let user = usersById[$0.userId]
      return UserPost(
        id: $0.id,
        userId: $0.userId,
        avatar: user?.avatar,
        username: user?.username,
        userEmail: user?.email,
        title: $0.title,
        description: $0.body,
        imageLoaded: false
      )
    }
  }

  private var imageCache = Dictionary<String, Data>(minimumCapacity: 100)
  private let queue = DispatchQueue(label: "com.leagueioschallenge.ImageCacheQueue")

  func getImage(_ url: String?, index: Int, completion: (() -> Void)? = nil) -> UIImage {
    if let url {
      if let imageData = imageCache[url] {
        return .init(data: imageData)!
      }
      else {
        Task {      
          let data = try await apiService.loadImageData(url)

          queue.sync {
            if imageCache.count > 200 {
              imageCache.removeAll(keepingCapacity: true) // limit memory overuse
            }
            imageCache[url] = data
          }

          let post = userPosts[index]
          if post.avatar == url {
            var updatedPostRecord = post
            updatedPostRecord.imageLoaded = true
            userPosts[index] = updatedPostRecord

            completion?()
          }
        }
      }
    }

    return UIImage(systemName: "person.fill")!
  }

  // MARK: - Navigation to User

  func userViewController(forTappedIndexPath indexPath: IndexPath) -> UIViewController {
    let post = userPosts[indexPath.row]
    let user = UserModel(
      avatar: post.avatar ?? "",
      username: post.username ?? "",
      email: post.userEmail ?? ""
    )

    return UIHostingController(
      rootView: UserView(
        apiService: apiService,
        user: user
      )
    )
  }

  // MARK: - Log Out

  var logOutButtonTitle: String {
    (apiService.currentLoginState() ?? .user).logOutButtonTitle
  }

  func logOut() -> LogOutAction {
    let loginState = apiService.currentLoginState() ?? .user
    apiService.logOut()
    switch loginState {
    case .guest:
      return .thankForTrialing
    case .user:
      return .goToLogin
    }
  }

  enum LogOutAction {
    case goToLogin
    case thankForTrialing
  }
}

private extension LoginState {
  var logOutButtonTitle: String {
    switch self {
    case .guest:
      "Exit"
    case .user:
      "Logout"
    }
  }
}

