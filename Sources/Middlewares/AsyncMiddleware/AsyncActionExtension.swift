//
//  AsyncAction.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Callback called when URLSession operation completes
public typealias URLSessionActionCompletionBlock = (Data?, URLResponse?, Error?, DispatchFunction) -> Void

/// Callback called when Disk IO read operation completes
public typealias DiskReadActionCompletionBlock = (Data?, DispatchFunction) -> Void

/// Callback called when Disk IO write operation completes
public typealias DiskWriteActionCompletionBlock = (Bool, DispatchFunction) -> Void


public struct URLSessionAsyncAction: AsyncAction {
  public var executionBlock: (MiddlewareAPI) -> ()

  /// Create a URLSession AsyncAction
  ///
  /// - Parameters:
  ///   - url: the url to fetch
  ///   - urlSession: the url session to use (optional)
  ///   - completionBlock: callback to call when the url operation is ended. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  init(url: URL,
       urlSession: URLSession = URLSession(configuration: .default),
       completionBlock: @escaping URLSessionActionCompletionBlock) {
    self.init(urlRequest: URLRequest(url: url), urlSession: urlSession, completionBlock: completionBlock)
  }

  /// Create a URLSession AsyncAction
  ///
  /// - Parameters:
  ///   - urlRequest: the url request to fetch
  ///   - urlSession: the url session to use (optional)
  ///   - completionBlock: callback to call when the url operation is ended. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  init(urlRequest: URLRequest,
       urlSession: URLSession = URLSession(configuration: .default),
       completionBlock: @escaping URLSessionActionCompletionBlock) {

    self.executionBlock = { api in
      urlSession.dataTask(with: urlRequest) { data, response, error in
        completionBlock(data, response, error, api.dispatch)
        }.resume()
    }
  }
}

public struct DiskReadAsyncAction: AsyncAction {
  static let defaultDispatchQueue = DispatchQueue(label: "DISK_READ_ASYNC_ACTION")

  public var executionBlock: (MiddlewareAPI) -> ()

  /// Create a Read DiskIO AsyncAction
  ///
  /// - Parameters:
  ///   - path: path to read from disk
  ///   - fileManager: the file manager to use (optional, defaults to FileManager.default)
  ///   - dispatchQueue: the dispatch queue to use when accessing disk (optional, defaults to `DispatchQueue(label: "IOMIDDLEWARE_IO_QUEUE"))
  ///   - completionBlock: callback to call when data is read from disk. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  public init(path: String,
              fileManager: FileManager = .default,
              dispatchQueue: DispatchQueue = defaultDispatchQueue,
              completionBlock: @escaping DiskReadActionCompletionBlock) {

    self.executionBlock = { api in

      dispatchQueue.async {
        if
          let data = fileManager.contents(atPath: path) {
          completionBlock(data, api.dispatch)
        }

      }
    }
  }

}

public struct DiskWriteAsyncAction: AsyncAction {
  static let defaultDispatchQueue = DispatchQueue(label: "DISK_WRITE_ASYNC_ACTION")

  public var executionBlock: (MiddlewareAPI) -> ()

  /// Create a Write DiskIO AsyncAction
  ///
  /// - Parameters:
  ///   - path: path to write to disk
  ///   - data: data to write to disk
  ///   - fileManager: the file manager to use (optional, defaults to FileManager.default)
  ///   - dispatchQueue: the dispatch queue to use when accessing disk (optional, defaults to `DispatchQueue(label: "IOMIDDLEWARE_IO_QUEUE"))
  ///   - completionBlock: callback to call when data is read from disk. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  public init(path: String,
              data: Data,
              fileManager: FileManager = .default,
              dispatchQueue: DispatchQueue = defaultDispatchQueue,
              completionBlock: @escaping DiskWriteActionCompletionBlock) {

    self.executionBlock = { api in

      dispatchQueue.async {
        let result = fileManager.createFile(atPath: path, contents: data, attributes: nil)
        completionBlock(result, api.dispatch)
      }
    }
  }

}
