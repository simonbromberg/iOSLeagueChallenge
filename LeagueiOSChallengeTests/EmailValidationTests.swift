//
//  EmailValidationTests.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-10.
//

import Testing
import LeagueiOSChallenge

struct EmailValidationTests {
  @Test func emptyString() {
    #expect("".isValidEmailDomain == false)
  }

  @Test func randomString() {
    #expect("loremipsom".isValidEmailDomain == false)
  }

  @Test func validDotComEmail() {
    #expect("hello@world.com".isValidEmailDomain)
  }

  @Test func validDotNetEmail() {
    #expect("foo@bar1.net".isValidEmailDomain)
  }

  @Test func validDotBizEmail() {
    #expect("a@b.biz".isValidEmailDomain)
  }

  @Test func dotComOutsideOfDomain() {
    #expect("com@b.ca".isValidEmailDomain == false)
    #expect("co@com.ca".isValidEmailDomain == false)
  }

  @Test func invalidDomains() {
    #expect("ab@abc.ca".isValidEmailDomain == false)
    #expect("ab@abc.org".isValidEmailDomain == false)
    #expect("ab@abc.pizza".isValidEmailDomain == false)
  }
}
