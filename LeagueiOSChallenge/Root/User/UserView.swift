//
//  UserView.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-12.
//

import SwiftUI

struct UserView: View {
  @Environment(\.dismiss) var dismiss

  let apiService: APIService
  let user: UserModel

  @State private var image = UIImage(systemName: "person")!

  var body: some View {
    NavigationStack {
      VStack(alignment: .center) {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 100)
          .clipShape(Circle())
          .overlay(
            Circle().stroke(Color.primaryText, lineWidth: 2)
          )
          .shadow(radius: 5)
          .onAppear() {
            loadImage()
          }
        Text(user.username)
          .foregroundStyle(Color.primaryText)
          .bold()
        HStack {
          Text(user.email)
            .foregroundStyle(Color.secondaryText)
          if user.email.isValidEmailDomain == false {
            Text("⚠️")
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.background)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(Color.primaryText)
          }
          .accessibilityIdentifier("closeButton")
        }
      }
    }
  }

  private func loadImage() {
    Task {
      let data = try await apiService.loadImageData(user.avatar)
      if let image = UIImage(data: data) {
        self.image = image
      }
    }
  }
}

#Preview {
  UserView(
    apiService: MockAPIHelper(),
    user: .init(
      avatar: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png",
      username: "bulbasaur",
      email: "bulbasaur@pokemon.com"
    )
  )
}
