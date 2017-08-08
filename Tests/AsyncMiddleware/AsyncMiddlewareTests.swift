//
//  AsyncMiddlewareTests.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

import XCTest
@testable import Suas

class AsyncMiddlewareTests: XCTestCase {
  
  func testItHandlesAsyncActionAndDispatchesIt() {
    var actionReceived: Action?
    var called = false

    let asyncMiddleware = AsyncMiddleware()
    let action = BlockAsyncAction { getState, dispatch in
      called = true
      dispatch(SomeAction())
    }
    
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { action in actionReceived = action },
                             next: { _ in })
    
    XCTAssert(called == true)
    XCTAssert(actionReceived is SomeAction)
  }
  
  func testItHandlesAsyncActionAndDispatchesItAsAStruct() {
    var actionReceived: Action?
    
    let asyncMiddleware = AsyncMiddleware()
    class TestAsyncAction: AsyncAction {
      static var called = false
      
      public func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
        TestAsyncAction.called = true
        dispatch(SomeAction())
      }
    }
    
    let action = TestAsyncAction()
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { action in actionReceived = action },
                             next: { _ in })
    
    XCTAssert(TestAsyncAction.called == true)
    XCTAssert(actionReceived is SomeAction)
  }
  
  func testAsyncFunctionGetsTheState() {
    let asyncMiddleware = AsyncMiddleware()
    
    let action = BlockAsyncAction { getState, dispatch in
      XCTAssertEqual(getState().value(forKey: "x", ofType: String.self), "x")
    }
    
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { _ in },
                             next: { _ in })
  }
  
  func testItHandlesAsyncActionAndDoesNotDispatchIt() {
    var actionReceived: Action?
    
    let asyncMiddleware = AsyncMiddleware()
    var called = false
    
    let action = BlockAsyncAction { getState, dispatch in
      called = true
    }
    
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { action in actionReceived = action },
                             next: { _ in })
    
    XCTAssert(called == true)
    XCTAssert(actionReceived == nil)
  }
  
  func testItPerformsAURLSessionAction() {
    var actionReceived: Action?
    
    let asyncMiddleware = AsyncMiddleware()
    var called = false
    
    let url = URL(string: "http://google.com")!
    var dataReturned: Data?
    
    let session = DummyURLSession()
    session.dataToReturn = Data()
    
    let action = URLSessionAsyncAction(
      url: url,
      urlSession: session
    ) { data, resp, error, dispatch in
      called = true
      dataReturned = data
      dispatch(SomeAction())
    }
    
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { action in actionReceived = action },
                             next: { _ in })
    
    XCTAssert(called == true)
    XCTAssert(dataReturned == session.dataToReturn)
    XCTAssert(actionReceived is SomeAction)
  }
  
  func testItPerformsADiskReadAction() {
    var actionReceived: Action?
    let exp = expectation(description: "x")
    
    let asyncMiddleware = AsyncMiddleware()
    var called = false
    var dataReturned: Data?
    
    let fileManager = DummyFileManager()
    fileManager.dataToReturn = Data()
    
    let action = DiskReadAsyncAction(
      path: "xxx",
      fileManager: fileManager
    ) { data, dispatch in
      called = true
      dataReturned = data
      dispatch(SomeAction())
      exp.fulfill()
    }
    
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { action in actionReceived = action },
                             next: { _ in })
    
    wait(for: [exp], timeout: 1)
    
    XCTAssert(called == true)
    XCTAssert(dataReturned == fileManager.dataToReturn)
    XCTAssert(actionReceived is SomeAction)
  }
  
  func testItPerformsADiskWriteAction() {
    var actionReceived: Action?
    let exp = expectation(description: "x")
    
    let asyncMiddleware = AsyncMiddleware()
    var called = false
    
    let dataToWrite = "x".data(using: .utf8)!
    let fileManager = DummyFileManager()
    fileManager.dataToReturn = Data()
    
    let action = DiskWriteAsyncAction(
      path: "xxx",
      data: dataToWrite,
      fileManager: fileManager
    ) { data, dispatch in
      called = true
      dispatch(SomeAction())
      exp.fulfill()
    }
    
    asyncMiddleware.onAction(action: action,
                             getState: { State(dictionary: ["x" : "x"]) },
                             dispatch: { action in actionReceived = action },
                             next: { _ in })
    
    wait(for: [exp], timeout: 1)
    
    XCTAssert(called == true)
    XCTAssert(fileManager.writtenPath == "xxx")
    XCTAssert(fileManager.writtenData == dataToWrite)
    XCTAssert(actionReceived is SomeAction)
  }
}


class DummyURLSession: URLSession {
  var dataToReturn: Data? = nil
  var urlResponse: URLResponse? = nil
  var error: Error? = nil
  
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    completionHandler(dataToReturn, urlResponse, error)
    return DummyURLSessionDataTask()
  }
}

class DummyURLSessionDataTask: URLSessionDataTask {
  override func resume() {
  }
}

struct URLResultAction: Action { }

class DummyFileManager: FileManager {
  
  var dataToReturn: Data? = nil
  var writtenPath: String?
  var writtenData: Data?
  
  override func contents(atPath path: String) -> Data? {
    return dataToReturn
  }
  
  override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
    writtenPath = path
    writtenData = data
    return true
  }
}
