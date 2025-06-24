//
//  JSONDecodingTests.swift
//  LeagueiOSChallengeTests
//
//  Created by Simon Bromberg on 2025-02-12.
//

import Testing
@testable import LeagueiOSChallenge

struct JSONDecodingTests {
  @Test func decodePosts() async throws {
    let mockAPI = MockAPIHelper()
    let posts = try await mockAPI.getPosts()
    #expect(posts.count == 1)

    let post = posts[0]
    #expect(post.userId == 1)
    #expect(post.id == 26)
    #expect(post.title == "est et quae odit qui non")
    #expect(post.body == "similique esse doloribus nihil ...")
  }

  @Test func decodeUsers() async throws {
    let mockAPI = MockAPIHelper()
    let users = try await mockAPI.getUsers()
    #expect(users.count == 1)

    let user = users[0]

    #expect(user.id == 1)
    #expect(user.avatar == "https://i.pravatar.cc/150?u=1")
    #expect(user.name == "Leanne Graham")
    #expect(user.username == "Bret")
    #expect(user.email == "Sincere@april.biz")
  }

}
