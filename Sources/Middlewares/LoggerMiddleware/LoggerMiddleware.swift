//
//  LoggerMiddleware.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// LoggerMiddleware that logs the action and state when each action is received
public class LoggerMiddleware: Middleware {
  
  public var api: MiddlewareAPI?
  public var next: DispatchFunction?
  
  private let showDuration: Bool
  private let showTimestamp: Bool
  private let lineLength: Int?
  private let logger: (String) -> Void
  private let predicate: ((State, Action) -> Bool)?
  private let stateTransformer: ((State) -> Any)?
  private let actionTransformer: ((Action) -> Any)?
  private let titleFormatter: ((Action, Date, UInt64) -> String)?
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    return formatter
  }()
  
  
  /// Create a LoggerMiddleware
  ///
  /// - Parameters:
  ///   - showTimestamp: show or hide the timestamp when receiving the action (optional, defaults to true)
  ///   - showDuration: show or hide the duration of reducing the action (optional, defaults to false)
  ///   - lineLength: specifies the maximum length of the printed lines (optional no max length)
  ///   - predicate: callback that decides if the logger should print or not (optional, defaults always print)
  ///   - titleFormatter: callback that defines the format of the log title (optional)
  ///   - stateTransformer: callback that allow converting the state to a differnt type before printing it (optional)
  ///   - actionTransformer: callback that allow converting the action to a differnt type before printing it (optional)
  ///   - logger: callback that receives the final string to print to console (optional, print to console)
  public init(
    showTimestamp: Bool = true,
    showDuration: Bool = false,
    lineLength: Int? = nil,
    predicate: ((State, Action) -> Bool)? = nil,
    titleFormatter: ((Action, Date, UInt64) -> String)? = nil,
    stateTransformer: ((State) -> Any)? = nil,
    actionTransformer: ((Action) -> Any)? = nil,
    logger: @escaping (String) -> Void = defaultLogger
    ) {
    self.showDuration = showDuration
    self.showTimestamp = showTimestamp
    self.predicate = predicate
    self.stateTransformer = stateTransformer
    self.actionTransformer = actionTransformer
    self.titleFormatter = titleFormatter
    self.lineLength = lineLength
    self.logger = logger
  }
  
  public func onAction(action: Action) {
    guard let api = api, let next = next else { return }
    
    if let predicate = predicate,
      predicate(api.state, action) == false {
      next(action)
      return
    }
    
    let oldState = transformedState(state: api.state)
    let startTime = DispatchTime.now()
    next(action)
    let endTime = DispatchTime.now()
    let newState = transformedState(state: api.state)
    
    let newAction = transformedAction(action: action)
    
    let firstLine = logTitle(action: action, startTime: startTime, endTime: endTime)
    logger([
      firstLine,
      LoggingParts.line(prefix: "├─ Prev state ► ", content: "\(oldState)", length: lineLength),
      LoggingParts.line(prefix: "├─ Action     ► ", content: "\(newAction)", length: lineLength),
      LoggingParts.line(prefix: "├─ Next state ► ", content: "\(newState)", length: lineLength),
      closingLine(length: firstLine.characters.count)
      ].joined(separator: "\n"))
  }
  
  private func logTitle(
    action: Action,
    startTime: DispatchTime,
    endTime: DispatchTime) -> String {
    let duration = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    
    if let titleFormatter = titleFormatter {
      return titleFormatter(action, Date(), duration)
    } else {
      return LoggingParts.title(
        action: action,
        duration: duration,
        date: Date(),
        showTimestamp: showTimestamp,
        showDuration: showDuration)
    }
  }
  
  private func closingLine(length: Int) -> String {
    return "└" + String.init(repeating: "─", count: length - 1)
  }
  
  private func transformedAction(action: Action) -> Any {
    guard let actionTransformer = actionTransformer else { return action }
    return actionTransformer(action)
  }
  
  private func transformedState(state: State) -> Any {
    guard let stateTransformer = stateTransformer else { return state }
    return stateTransformer(state)
  }
}

enum LoggingParts {
  
  static func title(
    action: Action,
    duration: UInt64,
    date: Date,
    showTimestamp: Bool,
    showDuration: Bool
    ) -> String {
    
    var parts = ["┌───→ Action: \(type(of: action))"]
    
    if showTimestamp {
      parts.append("@\(timestamp(forDate: date))")
    }
    
    if showDuration {
      parts.append("(in \(duration / 1000) µs)")
    }
    
    return parts.joined(separator: " ")
  }
  
  static func line(prefix: String, content: String, length: Int?) -> String {
    guard let lenght = length else { return prefix + content }
    
    let prefixLength = prefix.characters.count
    let lineLength = lenght - prefixLength - 1
    var restOfString = content
    var parts: [String] = []
    
    let firstPrefix = prefix
    let linesPrefix = "│" + String(repeatElement(" ", count: prefixLength - 1))
    
    while true {
      let prefixPart = parts.count == 0 ? firstPrefix : linesPrefix
      
      if restOfString.characters.count < lineLength {
        parts.append(prefixPart + restOfString)
        break
      } else {
        let index = restOfString.index(restOfString.startIndex, offsetBy: lineLength)
        let stringPart = restOfString.substring(to: index)
        restOfString = restOfString.substring(from: index)
        
        parts.append(prefixPart + stringPart)
      }
    }
    
    return parts.joined(separator: "\n")
  }
  
  private static func timestamp(forDate date: Date) -> String {
    return LoggerMiddleware.dateFormatter.string(from: date)
  }
  
}

public let defaultLogger = { (string: String) in
  print(string)
}

