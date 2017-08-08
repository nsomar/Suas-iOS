//
//  AsyncActionExtension.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Callback called when URLSession operation completes
public typealias URLSessionActionCompletionBlock = (Data?, URLResponse?, Error?, DispatchFunction) -> Void


/// URL Session `AsyncAction` implementation to fetch data from the network asynchronously. Requires `AsyncMiddleware` to be added to the store.
///
/// # Example
/// ```
/// let action = URLSessionAsyncAction(url: ...) { data, response, error, dispatch in
///   // Parse data and prepare models
///   dispatch(DataFetchedAction(parsed))
/// }
/// ```
public struct URLSessionAsyncAction: AsyncAction {

  private let urlSession: URLSession
  private let urlRequest: URLRequest
  private let completionBlock:  URLSessionActionCompletionBlock

  /// Create a URLSession AsyncAction
  ///
  /// - Parameters:
  ///   - url: the url to fetch
  ///   - urlSession: (optional) the url session to use. When not set a default one will be used.
  ///   - completionBlock: callback to call when the url operation is ended. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  public init(url: URL,
              urlSession: URLSession = URLSession(configuration: .default),
              completionBlock: @escaping URLSessionActionCompletionBlock) {
    self.init(urlRequest: URLRequest(url: url), urlSession: urlSession, completionBlock: completionBlock)
  }

  /// Create a URLSession AsyncAction
  ///
  /// - Parameters:
  ///   - urlRequest: the url request to fetch
  ///   - urlSession: (optional) the url session to use. When not set a default one will be used.
  ///   - completionBlock: callback to call when the url operation is ended. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  public init(urlRequest: URLRequest,
              urlSession: URLSession = URLSession(configuration: .default),
              completionBlock: @escaping URLSessionActionCompletionBlock) {
    self.urlRequest = urlRequest
    self.urlSession = urlSession
    self.completionBlock = completionBlock
  }

  public func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
    urlSession.dataTask(with: urlRequest) { data, response, error in
      self.completionBlock(data, response, error, dispatch)
      }.resume()
  }
}


/// Callback called when Disk IO read operation completes
public typealias DiskReadActionCompletionBlock = (Data?, DispatchFunction) -> Void


/// Disk Read `AsyncAction` implementation to read data from the disk asynchronously. Requires `AsyncMiddleware` to be added to the store.
///
/// # Example
/// ```
/// let action = DiskReadAsyncAction(path: ...) { data, dispatch in
///   // Dispatch a new action
///   dispatch(DataFetchedAction(data))
/// }
/// ```
public struct DiskReadAsyncAction: AsyncAction {
  static let defaultDispatchQueue = DispatchQueue(label: "DISK_READ_ASYNC_ACTION")

  private let path: String
  private let fileManager: FileManager
  private let dispatchQueue: DispatchQueue
  private let completionBlock: DiskReadActionCompletionBlock

  /// Create a Read DiskIO AsyncAction
  ///
  /// - Parameters:
  ///   - path: path to read from disk
  ///   - fileManager: (optional) the file manager to use. When not passed it defaults to `FileManager.default`
  ///   - dispatchQueue: (optional) the dispatch queue to use when accessing disk. When not passed it defaults to `DispatchQueue(label: "IOMIDDLEWARE_IO_QUEUE")
  ///   - completionBlock: callback to call when data is read from disk. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  public init(path: String,
              fileManager: FileManager = .default,
              dispatchQueue: DispatchQueue = defaultDispatchQueue,
              completionBlock: @escaping DiskReadActionCompletionBlock) {
    self.path = path
    self.fileManager = fileManager
    self.dispatchQueue = dispatchQueue
    self.completionBlock = completionBlock
  }

  public func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
    dispatchQueue.async {
      if
        let data = self.fileManager.contents(atPath: self.path) {
        self.completionBlock(data, dispatch)
      }
    }
  }

}


/// Callback called when Disk IO write operation completes
public typealias DiskWriteActionCompletionBlock = (Bool, DispatchFunction) -> Void


/// Disk Write `AsyncAction` implementation to write data to the disk asynchronously. Requires `AsyncMiddleware` to be added to the store.
///
/// # Example
/// ```
/// let action = DiskWriteAsyncAction(path: ..., data: ...) { succeeded, dispatch in
///   // After data is written, dispatch an action
///   dispatch(DataWrittenToDisk(succeeded))
/// }
/// ```
public struct DiskWriteAsyncAction: AsyncAction {
  static let defaultDispatchQueue = DispatchQueue(label: "DISK_WRITE_ASYNC_ACTION")

  private let path: String
  private let data: Data
  private let fileManager: FileManager
  private let dispatchQueue: DispatchQueue
  private let completionBlock: DiskWriteActionCompletionBlock

  /// Create a Write DiskIO AsyncAction
  ///
  /// - Parameters:
  ///   - path: path to write to disk
  ///   - data: data to write to disk
  ///   - fileManager: (optional) the file manager to use. When not passed it defaults to `FileManager.default`
  ///   - dispatchQueue: (optional) the dispatch queue to use when accessing disk. When not passed it defaults to `DispatchQueue(label: "IOMIDDLEWARE_IO_QUEUE")
  ///   - completionBlock: callback to call when data is read from disk. In this block `dispatch` is used to dispatch new actions
  /// - Returns: an async action to dispatch
  public init(path: String,
              data: Data,
              fileManager: FileManager = .default,
              dispatchQueue: DispatchQueue = defaultDispatchQueue,
              completionBlock: @escaping DiskWriteActionCompletionBlock) {

    self.path = path
    self.data = data
    self.fileManager = fileManager
    self.dispatchQueue = dispatchQueue
    self.completionBlock = completionBlock
  }

  public func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
    dispatchQueue.async {
      let result = self.fileManager.createFile(atPath: self.path, contents: self.data, attributes: nil)
      self.completionBlock(result, dispatch)
    }
  }
}
