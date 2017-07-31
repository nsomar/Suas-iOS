//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import Suas

class ReducerTests: XCTestCase {
  func testItReducesWithABlockWithState() {
    let state = MyState1(value: 0)
    let newState = reducer1.reduce(action: IncrementAction(), state: state)

    XCTAssertEqual((newState as! MyState1).value, 1)
  }

  func testItReducesWithAClassWithState() {
    let state = MyState1(value: 0)
    let r = Reducer1()
    let newState = r.reduce(action: IncrementAction(), state: state)

    XCTAssertEqual(newState!.value, 20)
  }

  func testItReturnSameStateIfCannotConvert() {
    let newState = reducer1.reduce(action: IncrementAction(), state: 1)

    XCTAssertEqual((newState as! Int), 1)
  }

  func testItReturnSameStateIfCannotConvertForCombinedReducer() {
    let (newState, _) = (Reducer1() |> Reducer2()).reduce(action: IncrementAction(), state: 1) as! (Int, [String])

    XCTAssertEqual(newState, 1)
  }

  func testItReturnSameStateIfCannotConvertForCombinedReducerWhenStateIsWrongForAReducer() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState1(value: 0),
      ]

    let (newState, _) = (Reducer1() |> Reducer2()).reduce(action: IncrementAction(),
                                                     state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v2 = newState.value(forKeyOfType: MyState2.self)?.blink ?? 0

    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v2, 0)
  }

  func testItReducesWithAClassWithStateCombine() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      ]

    let combine = Reducer1() |> Reducer2()
    let (newState, _) = combine.reduce(action: IncrementAction(),
                                  state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v2 = newState.value(forKeyOfType: MyState2.self)!.blink
    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v2, 40)
  }

  func testItDoesNotAddTheSameReducerTwice() {
    let combine = Reducer1() |> Reducer1()
    XCTAssertEqual(combine.reducers.count, 1)
  }

  func testItReducesWithAClassWithStateCombineThreeItems() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      ]

    let combine = Reducer1() |> Reducer2() |> Reducer3()
    let (newState, _) = combine.reduce(action: IncrementAction(),
                                  state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v2 = newState.value(forKeyOfType: MyState2.self)!.blink
    let v3 = newState.value(forKeyOfType: MyState3.self)!.otherVal

    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v2, 40)
    XCTAssertEqual(v3, 60)
  }

  func testItWarsWhenAStateIsMissingForAReducer() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      ]

    let combine = Reducer1() |> Reducer2() |> Reducer3()
    let (newState, _) = combine.reduce(action: IncrementAction(),
                                  state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v3 = newState.value(forKeyOfType: MyState3.self)!.otherVal

    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v3, 60)
  }

  func testItReducesWithAClassWithStateCombineThreeItemsCombinerComesLast() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      ]

    let combiner1 = Reducer2() |> Reducer3()
    let combine = Reducer1() |> combiner1
    let (newState, _) = combine.reduce(action: IncrementAction(),
                                  state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v2 = newState.value(forKeyOfType: MyState2.self)!.blink
    let v3 = newState.value(forKeyOfType: MyState3.self)!.otherVal

    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v2, 40)
    XCTAssertEqual(v3, 60)
  }

  func testItReducesWithAClassWithStateCombineThreeItemsCombinerComesFirst() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      ]

    let combiner1 = Reducer2() |> Reducer3()
    let combine = combiner1 |> Reducer1()
    let (newState, _) = combine.reduce(action: IncrementAction(),
                                  state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v2 = newState.value(forKeyOfType: MyState2.self)!.blink
    let v3 = newState.value(forKeyOfType: MyState3.self)!.otherVal

    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v2, 40)
    XCTAssertEqual(v3, 60)
  }

  func testItReturnsWhichKeysAreChanged() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      ]

    let combine = Reducer2() |> Reducer3() |> Reducer1()
    let (_, keys) = combine.reduce(action: IncrementAction(), state: State(dictionary: state)) as! (State, [String])
    XCTAssertEqual(keys, ["MyState2", "MyState3", "MyState1"])
  }

  func testItGetsOnlyKeysThatChanged() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      ]

    let combine = Reducer2() |> Reducer3Nil() |> Reducer1()
    let (_, keys) = combine.reduce(action: IncrementAction(), state: State(dictionary: state)) as! (State, [String])
    XCTAssertEqual(keys, ["MyState2", "MyState1"])
  }

  func testReturningNilFor1ReducerOnlyDoesNotCrash() {
    let x = Reducer3Nil().reduce(action: IncrementAction(), state: MyState3(otherVal: 30))
    XCTAssertNil(x)
  }

  func testItReducesWithAClassWithStateCombineFourItems2Combiners() {
    let state: [StateKey: Any] = [
      "\(MyState1.self)": MyState1(value: 0),
      "\(MyState2.self)": MyState2(blink: 0),
      "\(MyState3.self)": MyState3(otherVal: 0),
      "\(MyState4.self)": MyState4(yetMoreVal: 0)
    ]

    let combiner1 = Reducer1() |> Reducer2()
    let combiner2 = Reducer3() |> Reducer4()
    let combine = combiner1 |> combiner2
    let (newState, _) = combine.reduce(action: IncrementAction(),
                                  state: State(dictionary: state)) as! (State, [String])

    let v1 = newState.value(forKeyOfType: MyState1.self)!.value
    let v2 = newState.value(forKeyOfType: MyState2.self)!.blink
    let v3 = newState.value(forKeyOfType: MyState3.self)!.otherVal
    let v4 = newState.value(forKeyOfType: MyState4.self)!.yetMoreVal

    XCTAssertEqual(v1, 20)
    XCTAssertEqual(v2, 40)
    XCTAssertEqual(v3, 60)
    XCTAssertEqual(v4, 70)
  }

  /// State Generation

  func testItGenereateCorrectStateWithAClassWithState() {
    let r = Reducer1()
    let initial = r.initialState

    XCTAssertEqual(initial.value, 10)
  }

  func testItGenereateCorrectStateWithAClassWithStateCombine() {
    let combine = Reducer1() |> Reducer2()
    let initial = combine.initialState

    let v1 = ((initial as! [String: Any])["\(MyState1.self)"] as! MyState1).value
    let v2 = ((initial as! [String: Any])["\(MyState2.self)"] as! MyState2).blink
    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, 20)
  }

  func testItGenereateCorrectStateWithAClassWithStateCombineThreeItems() {
    let combine = Reducer1() |> Reducer2() |> Reducer3()
    let initial = combine.initialState

    let v1 = ((initial as! [String: Any])["\(MyState1.self)"] as! MyState1).value
    let v2 = ((initial as! [String: Any])["\(MyState2.self)"] as! MyState2).blink
    let v3 = ((initial as! [String: Any])["\(MyState3.self)"] as! MyState3).otherVal
    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, 20)
    XCTAssertEqual(v3, 30)
  }

  func testItGenereateCorrectStateWithAClassWithStateCombineThreeItemsCombinerComesLast() {
    let combiner1 = Reducer2() |> Reducer3()
    let combine = Reducer1() |> combiner1
    let initial = combine.initialState

    let v1 = ((initial as! [String: Any])["\(MyState1.self)"] as! MyState1).value
    let v2 = ((initial as! [String: Any])["\(MyState2.self)"] as! MyState2).blink
    let v3 = ((initial as! [String: Any])["\(MyState3.self)"] as! MyState3).otherVal
    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, 20)
    XCTAssertEqual(v3, 30)
  }

  func testItGenereateCorrectStateWithAClassWithStateCombineThreeItemsCombinerComesFirst() {
    let combiner1 = Reducer2() |> Reducer3()
    let combine = combiner1 |> Reducer1()
    let initial = combine.initialState

    let v1 = ((initial as! [String: Any])["\(MyState1.self)"] as! MyState1).value
    let v2 = ((initial as! [String: Any])["\(MyState2.self)"] as! MyState2).blink
    let v3 = ((initial as! [String: Any])["\(MyState3.self)"] as! MyState3).otherVal
    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, 20)
    XCTAssertEqual(v3, 30)
  }

  func testItGenereateCorrectStateWithAClassWithStateCombineFourItems2Combiners() {
    let combiner1 = Reducer1() |> Reducer2()
    let combiner2 = Reducer3() |> Reducer4()
    let combine = combiner1 |> combiner2
    let initial = combine.initialState

    let v1 = ((initial as! [String: Any])["\(MyState1.self)"] as! MyState1).value
    let v2 = ((initial as! [String: Any])["\(MyState2.self)"] as! MyState2).blink
    let v3 = ((initial as! [String: Any])["\(MyState3.self)"] as! MyState3).otherVal
    let v4 = ((initial as! [String: Any])["\(MyState4.self)"] as! MyState4).yetMoreVal

    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, 20)
    XCTAssertEqual(v3, 30)
    XCTAssertEqual(v4, 40)
  }
}

