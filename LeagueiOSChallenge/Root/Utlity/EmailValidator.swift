//
//  EmailValidator.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-10.
//

import Foundation

extension String {
  public var isValidEmailDomain: Bool {
    !ranges(of: /^.*\.(com|net|biz)/).isEmpty
  }
}
