//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import SuasIOS

class ComponentTests: XCTestCase {

  func testItSetsTheStateAlwaysIfItDoesNotImplementEquatable() {
    let component = MyComponent()
    component.setIfChanged(MyState1(value: 10))
    component.didSetCalled = false
    component.setIfChanged(MyState1(value: 10))

    XCTAssertEqual(component.didSetCalled, true)
  }

  func testItDoesNotSetTheStateIfItImplementEquatable() {
    let component = MyComponentWithEquatableState()
    component.setIfChanged(MyEquatableState1(val: 10))
    component.didSetCalled = false
    component.setIfChanged(MyEquatableState1(val: 10))

    XCTAssertEqual(component.didSetCalled, false)

    component.setIfChanged(MyEquatableState1(val: 20))

    XCTAssertEqual(component.didSetCalled, true)
  }

  func testWeCanConnectAStoreToAComponent() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    store.connect(component: component)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 11)
  }

  func testWeCanDisconnectAStoreFromAComponent() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    store.connect(component: component)
    store.disconnect(component: component)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 10)
  }

  func testComponentCanConnectToASpecificStateKey() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponent()

    component.state = MyState1(value: 0)
    store.connect(component: component, forStateKey: "MyState1")
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 10)
  }

  func testComponentRemovesListenerWhenComponentDeinit() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    callAndForget(store: store)
    store.dispatch(action: IncrementAction())
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 0)
  }

  func callAndForget(store: Store) {
    let component = MyComponent()

    component.state = MyState1(value: 0)
    store.connect(component: component, forStateKey: "MyState1")
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 1)
  }

  func testComponentWithStateConverter() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<StoreState, StrangeState> { state in
      return StrangeState(strangeValue: state.value(forKeyOfType: MyState1.self)?.value ?? -1)
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, withStateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 10)
  }

  func testComponentWithStateConverterForAKey() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<MyState1, StrangeState> { state in
      return StrangeState(strangeValue: state.value)
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, forStateKey: "MyState1", withStateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 10)
  }

  func testComponentWithStateConverterForAKeyThatDoesNotConvert() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<MyState1, StrangeState> { state in
      return nil
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, forStateKey: "MyState1", withStateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 0)
  }

  func testConnectsToComponentWithStateConverterThatCannotConvert() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<StoreState, StrangeState> { state in
      return nil
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, withStateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 0)
  }

  func testConnectsToComponentWithListener() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponent()

    component.state = MyState1(value: 2)
    store.connect(component: component) { newState in
      XCTAssertEqual(newState.value(forKeyOfType: MyState1.self)?.value, 10)
    }

    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 2)
  }

  func testConnectsToComponentWithListenerWithStateKey() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponent()

    component.state = MyState1(value: 2)
    store.connect(component: component, forStateKey: "MyState1") { newState in
      XCTAssertEqual(newState.value, 10)
    }

    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 2)
  }

  func testConnectsToComponentMultipleTimes() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponent()

    component.state = MyState1(value: 2)

    store.connect(component: component)
    store.connect(component: component) { newState in
      XCTAssertEqual(newState.value(forKeyOfType: MyState1.self)?.value, 10)
    }

    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 10)
  }

  func testConnectsToComponentMultipleTimesAndCanRemoveThem() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponent()

    component.state = MyState1(value: 2)

    store.connect(component: component)
    store.connect(component: component) { newState in
      XCTAssertEqual(newState.value(forKeyOfType: MyState1.self)?.value, 10)
    }

    XCTAssertEqual(Suas.allListeners(inStore: store).count, 2)
    store.disconnect(component: component)
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 0)
  }

  func testConnectsToComponentMultipleTimesAndCanRemoveThemOnDeinit() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    callAndForget2(store: store)
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 0)
  }

  func callAndForget2(store: Store) {
    let component = MyComponent()

    component.state = MyState1(value: 2)

    store.connect(component: component)
    store.connect(component: component) { newState in
      XCTAssertEqual(newState.value(forKeyOfType: MyState1.self)?.value, 10)
    }

    XCTAssertEqual(Suas.allListeners(inStore: store).count, 2)
  }

  // Notifier

  func testWeCanConnectAStoreToAComponentWithNotifierThatAlwaysNotifies() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    store.connect(component: component, withNotifier: notifier)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 11)
  }

  func testWeCanConnectAStoreToAComponentWithNotifierAndStateKeyThatAlwaysNotifies() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    store.connect(component: component, forStateKey: "MyState1", withNotifier: notifier)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 11)
  }

  func testWeCanConnectAStoreToAComponentWithNotifierThatNotifiesConditionally() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in
      if new.value == 11 {
        l.notify(new)
      }
    }

    store.connect(component: component, withNotifier: notifier)

    store.dispatch(action: IncrementAction())
    XCTAssertEqual(component.state.value, 11)

    store.dispatch(action: IncrementAction())
    XCTAssertEqual(component.state.value, 11)
  }

  func testConnectsComponentWithNotifierThatCompares() {
    let store = Suas.createStore(reducer: EquatableReducer(),
                                 state: MyEquatableState1(val: 10))
    let component = MyComponentWithEquatableState()

    struct NoAction: Action { }

    store.connect(component: component, withNotifier: compareNotifier)
    store.dispatch(action: NoAction())

    XCTAssertEqual(component.state.val, 10)
    XCTAssertEqual(component.didSetCalled, false)
  }

  func testConnectsComponentWithNotifierThatComparesAndCalls() {
    let store = Suas.createStore(reducer: EquatableReducer(),
                                 state: MyEquatableState1(val: 10))
    let component = MyComponentWithEquatableState()

    store.connect(component: component, withNotifier: compareNotifier)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.val, 80)
    XCTAssertEqual(component.didSetCalled, true)
  }
}
