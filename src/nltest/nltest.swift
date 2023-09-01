//
//  nltest.swift
//

import Foundation
import NorthLib
import ArgumentParser

@main
class NorthLibTest: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    commandName: "nltest",
    abstract: "Some NorthLib test functions",
    subcommands: [
      FakeLogin.self,
    ]
  )

  required init() {}
}

class FakeLogin: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    commandName: "login",
    abstract: "Fakes login prompt",
    discussion: """
      Just a test for NorthLib Console class.
    """
  )

  func fakeLogin() async throws {
    let con = Console()
    con.puts("login: ")
    if let login = await con.gets() { 
      con.puts("password: ")
      if let password = await con.negets() { 
        con.putsln("login: \(login)")
        con.putsln("password: \(password)")
      }
    }
  }

  func run() {
    let sema = DispatchSemaphore(value: 0)
    Task { 
      try! await fakeLogin()
      sema.signal()
    }
    sema.wait()
  }
  
  required init() {}
}
