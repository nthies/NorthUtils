//
//  chfn.swift
//
//  Created by Norbert Thies on 16.02.22.
//  Copyright © 2022 Norbert Thies. All rights reserved.
//

import NorthLib
import NorthLowLevel
import ArgumentParser

@main
class Chfn: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    abstract: "Change file names using eg. regular expressions.",
    discussion: """
    This small tool is used to change the name of files given on the command 
    line or read from the standard input (eg. the output of find).
    By default only the prefix of the filenames is matched and changed, to 
    apply the 'operation' to the complete basename of the file use 
    the '-c' option. File names are structured as follows:
        <filename> = <path>/<basename>
        <basename> = <prefix>.<extension>
    <basenames> may not contain slashes(/).
    If no file arguments are given, the file names to change will be read 
    from STDIN.
    """)

  @Flag(name: .shortAndLong, help: "Change complete names (including extension).")
  var complete: Bool = false

  @Flag(name: .shortAndLong, help: "Change the extension only.")
  var extonly: Bool = false

  @Flag(name: .shortAndLong, help: "Overwrite existing files.")
  var force: Bool = false

  @Flag(name: .shortAndLong, help: "List changes only, don't change names.")
  var list: Bool = false
  
  @Flag(name: .shortAndLong, help: "Verbose mode - list files changed.")
  var verbose: Bool = false
  
  @Option(name: .shortAndLong, help: "Destination directory.")
  var destdir: String = ""
  
  @Option(name: .shortAndLong, help: "Number of digits for #-substitution.")
  var ndigits: Int = -1
  
  @Option(name: .shortAndLong, help: "Start index for #-substitution.")
  var startIndex: Int = 1

  @Argument(help: "<subst> | lower | upper | help\nuse 'help' to get more info.")
  var operation: String
  
  @Argument(help: "Names of files to rename, \"-\" for STDIN")
  var files: [String] = ["-"]
  
  /// Sustitution expression
  static var sexpr: Substexpr?
  
  func showRegexprHelp() {
    let rehelp = """
    Operation
      The change file 'operation' may be one of:
        - lower:    convert file(-part) to lower case (eg. ABC -> abc)
        - upper:    convert file(-part) to upper case (eg. abc -> ABC)
        - <subst>:  sed-like substitution specification
    Substitution
      The substitution specification <subst> consists of two parts, the first is
      a regular expression (eg. '\\d+') and the second a replacement string.
      Or formal:
        <delimiter><pattern><delimiter><replacement><delimiter>[g]
      The <delimiter> is a single ASCII character (eg. '/'). If the
      last <delimiter> is followed by a 'g', the substitution is applied
      globally, ie. all matches of <pattern> in the file name are substituted
      with <replacement>. The replacement string may contain backreferences
      to the matching pattern or pattern group:
        &        : refers to the complete matching string
        \\1 or &1 : refers to the 1st matching group
        \\i or &i : refers to the i'th matching group
      In addition the replacement string may contain a sequence of '#' chars
      which will be replaced by the numeric postion of the file in the list of 
      all files to substitute. The number of '#' chars define the number of
      digits used.
    """
    print(rehelp)
  }
  
  func fromStdin() throws -> [String] {
    var fnames: [String] = []
    try File.open(path: "-") { f in
      while let fn = f.readline() {
        if File(fn).exists { fnames += fn }
        else { throw "\(fn): not found" }
      }
    }
    return fnames
  }
  
  func subst(_ name: String) -> String? { Chfn.sexpr?.subst(name) }
  
  func substName(basename: String, prefix: String, ext: String?) -> String? {
    if complete {
      if let s = subst(basename) { return s }
    } 
    else if extonly {
      if ext != nil, let s = subst(ext!) { return "\(prefix).\(s)" }
    }
    else {
      if let s = subst(prefix) { 
        if ext != nil { return "\(s).\(ext!)" }
        else { return s } 
      }
    }
    return nil
  }
  
  func cased(_ name: String, _ isLower: Bool) -> String {
    isLower ? name.lowercased() : name.uppercased()
  }
  
  func changeCase(basename: String, prefix: String, ext: String?, isLower: Bool)
    -> String? {
    if complete { return cased(basename, isLower) }
    else if extonly {
      if ext != nil { return "\(prefix).\(cased(ext!, isLower))" }
    }
    else {
      if ext != nil { return "\(cased(prefix, isLower)).\(ext!)" }
      else { return cased(prefix, isLower) }
    }
    return nil
  }
  
  func changeNames(_ fnames: [String]) {
    for fn in fnames {
      let dir = File.dirname(fn)
      let base = File.basename(fn)
      let pref = File.progname(fn)
      let ext = File.extname(fn)
      var dest: String? = nil
      switch operation {
        case "lower": dest = changeCase(basename: base, prefix: pref, ext: ext, 
                                        isLower: true)
        case "upper": dest = changeCase(basename: base, prefix: pref, ext: ext, 
                                        isLower: false)
        default: dest = substName(basename: base, prefix: pref, ext: ext)
      }
      if let dest = dest {
        var destpath: String
        if self.destdir != "" { destpath = "\(self.destdir)/\(dest)" }
        else if dir != "." { destpath = "\(dir)/\(dest)" }
        else { destpath = dest }
        if verbose || list { print("\(fn) -> \(destpath)") }
        if !list { File(fn).move(to: destpath, isOverwrite: force) }
      }
    } 
  }
  
  func run() throws {
    switch operation {
      case "help": showRegexprHelp(); return
      case "lower": break;
      case "upper": break;
      default:
        try Chfn.sexpr = Substexpr(operation)
        Chfn.sexpr?.index = startIndex
        if ndigits != -1 { Chfn.sexpr?.ndig = ndigits }
    }
    var fnames: [String] = []
    for fn in files {
      if fn == "-" { fnames.append(contentsOf: try fromStdin()) }
      else {
        if File(fn).exists { fnames += fn }
        else { throw "\(fn): not found" }
      }
    }
    Chfn.sexpr?.count = fnames.count
    changeNames(fnames)
  }
  
  required init() {}

}
