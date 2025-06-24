//
//  ImageCache.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-12.
//

import UIKit
import CryptoKit

struct ImageCache {
  static var manager: FileManager {
    .default
  }

  static func saveImageData(imageData: Data, to urlString: String) {
    let directory = manager.cacheDirectory

    do {
      try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

      let imagePath = directory.appendingPathComponent(urlString.hashed)
      try imageData.write(to: imagePath)
    } catch {
      print(error)
    }
  }

  static func fetchImageData(_ urlString: String) -> Data? {
    let url = manager.cacheDirectory.appendingPathComponent(urlString.hashed)
    guard manager.fileExists(atPath: url.path) else {
      return nil
    }

    guard let imageData = try? Data(contentsOf: url) else {
      return nil
    }

    return imageData
  }
}

private extension FileManager {
  var cacheDirectory: URL {
    urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "PokeBowlCache")
  }
}

private extension String {
  var hashed: String {
    SHA256.hash(data: Data(utf8)).compactMap { String(format: "%02x", $0) }.joined()
  }
}
