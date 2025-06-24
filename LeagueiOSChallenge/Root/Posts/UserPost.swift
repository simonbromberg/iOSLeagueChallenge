//
//  UserPost.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-11.
//

import Foundation

struct UserPost: Hashable {
  let id: Int

  let userId: Int
  let avatar: String?
  let username: String?
  let userEmail: String?
  
  let title: String
  let description: String

  var imageLoaded: Bool
}
