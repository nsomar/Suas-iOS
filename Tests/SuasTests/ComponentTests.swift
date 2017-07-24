//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import Suas

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
    store.connect(component: component, stateKey: "MyState1")
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 30)
    XCTAssertTrue(component.didSetCalled)
  }

  func testItDoesNotInformIfStateDidNotChange() {
    let store = Suas.createStore(reducer: Reducer1Nil() |> Reducer2())
    let component = MyComponent()

    component.state = MyState1(value: 0)

    store.connect(component: component)
    component.didSetCalled = false

    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 10)
    XCTAssertFalse(component.didSetCalled)
  }

  func testItDoesNotInformIfStateDidNotChangeWith1Reducer() {
    let store = Suas.createStore(reducer: Reducer1Nil())
    let component = MyComponent()

    component.state = MyState1(value: 0)
    store.connect(component: component)
    component.didSetCalled = false

    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 10)
    XCTAssertFalse(component.didSetCalled)
  }

  func testComponentRemovesListenerWhenComponentDeinit() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    callAndForget(store: store)
    store.dispatch(action: IncrementAction())
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 0)
  }

  func testItResetsTheStateForAComponent() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponent()

    store.reset(state: MyState1(value: 1), forComponent: component)
    XCTAssertEqual(store.state.value(forKeyOfType: MyState1.self)?.value, 1)
  }

  func callAndForget(store: Store) {
    let component = MyComponent()

    component.state = MyState1(value: 0)
    store.connect(component: component, stateKey: "MyState1")
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 1)
  }

  func testComponentWithStateConverter() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<StoreState, StrangeState> { state in
      return StrangeState(strangeValue: state.value(forKeyOfType: MyState1.self)?.value ?? -1)
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, stateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 30)
  }

  func testComponentWithStateConverterForAKey() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<MyState1, StrangeState> { state in
      return StrangeState(strangeValue: state.value)
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, stateKey: "MyState1", stateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 30)
  }

  func testComponentWithStateConverterForAKeyThatDoesNotConvert() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    let component = MyComponentWithStrangeState()

    let strangeStateConverter = StateConverter<MyState1, StrangeState> { state in
      return nil
    }

    component.state = StrangeState(strangeValue: 0)
    store.connect(component: component, stateKey: "MyState1", stateConverter: strangeStateConverter)
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
    store.connect(component: component, stateConverter: strangeStateConverter)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.strangeValue, 0)
  }

  // Notifier

  func testWeCanConnectAStoreToAComponentWithNotifierThatAlwaysNotifies() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    store.connect(component: component, notifier: notifier)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 11)
  }

  func testWeCanConnectAStoreToAComponentWithNotifierAndStateKeyThatAlwaysNotifies() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    store.connect(component: component, stateKey: "MyState1", notifier: notifier)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.value, 11)
  }

  func testItSetsInitalValue() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 100))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    component.didSetCalled = false
    store.connect(component: component, stateKey: "MyState1", notifier: notifier)

    XCTAssertEqual(component.state.value, 100)
    XCTAssertTrue(component.didSetCalled)
  }

  func testWeCanConnectAStoreToAComponentWithNotifierThatNotifiesConditionally() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    let notifier: ListenerNotifier<MyState1> = { new, old, l in
      if new.value == 11 {
        l.notify(new)
      }
    }

    store.connect(component: component, notifier: notifier)

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

    store.connect(component: component, notifier: compareNotifier)
    component.didSetCalled = false

    store.dispatch(action: NoAction())

    XCTAssertEqual(component.state.val, 10)
    XCTAssertEqual(component.didSetCalled, false)
  }

  func testConnectsComponentWithNotifierThatComparesAndCalls() {
    let store = Suas.createStore(reducer: EquatableReducer(),
                                 state: MyEquatableState1(val: 10))
    let component = MyComponentWithEquatableState()

    store.connect(component: component, notifier: compareNotifier)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(component.state.val, 80)
    XCTAssertEqual(component.didSetCalled, true)
  }

  func testItConnectsAnActionListener() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    var actionReceived: Action? = nil
    store.connectActionListener(toComponent: component) { action in
      actionReceived = action
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(actionReceived is IncrementAction)
  }

  func testItDisconnectsAnActionListenersOnDisconnect() {
    let store = Suas.createStore(reducer: reducer1, state: MyState1(value: 10))
    let component = MyComponent()

    var actionReceived: Action? = nil
    store.connectActionListener(toComponent: component) { action in
      actionReceived = action
    }
    store.disconnect(component: component)

    store.dispatch(action: IncrementAction())
    XCTAssertNil(actionReceived)
  }

  func testItDisconnectsAnActionListenersOnDisconnectActionListener() {
    let store = Suas.createStore(reducer: Reducer1(), state: MyState1(value: 5))
    let component = MyComponent()

    var actionReceived: Action? = nil
    store.connectActionListener(toComponent: component) { action in
      actionReceived = action
    }
    
    store.disconnectActionListener(forComponent: component)

    store.dispatch(action: IncrementAction())
    XCTAssertNil(actionReceived)
  }

  func testItDisconnectsAnActionListenersOnDeinit() {
    let store = Suas.createStore(reducer: Reducer1(), state: MyState1(value: 5))
    callAndForget2(store: store)
    XCTAssertEqual(Suas.allActionListeners(inStore: store).count, 0)
  }

  func callAndForget2(store: Store) {
    let component = MyComponent()

    store.connectActionListener(toComponent: component) { action in
    }

    XCTAssertEqual(Suas.allActionListeners(inStore: store).count, 1)
  }
}
