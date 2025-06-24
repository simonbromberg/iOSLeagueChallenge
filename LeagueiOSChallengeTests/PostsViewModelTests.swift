//
//  PostsViewModelTests.swift
//  LeagueiOSChallengeTests
//
//  Created by Simon Bromberg on 2025-02-13.
//

import Testing
@testable import LeagueiOSChallenge

struct PostsViewModelTests {
  @Test func fetchPostsAndImage() async throws {
    let viewModel = PostsViewModel(apiService: MockAPIHelper())
    try await viewModel.fetchPosts()
    #expect(viewModel.userPosts.count == 1)

    let post = viewModel.userPosts[0]

    #expect(post.id == 26)
    #expect(post.userId == 1)
    #expect(post.title == "est et quae odit qui non")
    #expect(post.description == "similique esse doloribus nihil ...")
    #expect(post.imageLoaded == false)

    #expect(post.username == "Bret")
    #expect(post.userEmail == "Sincere@april.biz")
    #expect(post.avatar == "https://i.pravatar.cc/150?u=1")


    await confirmation{ confirmation in
      await withCheckedContinuation { continuation in
        _ = viewModel.getImage(post.avatar, index: 0) {
          #expect(viewModel.userPosts[0].imageLoaded)
          confirmation()
          continuation.resume()
        }
      }
    }
  }

  @Test func logInAsUser() async throws {
    let apiHelper = MockAPIHelper()
    try await apiHelper.logIn(username: "foo", password: "bar")

    let viewModel = PostsViewModel(apiService: apiHelper)
    #expect(viewModel.logOutButtonTitle == "Logout")

    let logOutAction = viewModel.logOut()
    #expect(logOutAction == .goToLogin)
  }

  @Test func logInAsGuest() async throws {
    let apiHelper = MockAPIHelper()
    try await apiHelper.logInAsGuest()

    let viewModel = PostsViewModel(apiService: apiHelper)
    #expect(viewModel.logOutButtonTitle == "Exit")

    let logOutAction = viewModel.logOut()
    #expect(logOutAction == .thankForTrialing)
  }
}
