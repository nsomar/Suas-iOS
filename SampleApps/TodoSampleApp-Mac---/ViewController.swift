//
//  ViewController.swift
//  TodoSampleApp-Mac
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Cocoa
import SuasMac

class ViewController: NSViewController, Component {

  @IBOutlet weak var todoTextField: NSTextField!
  @IBOutlet weak var todoTableView: NSTableView!

  var state: TodoState = emptyState {
    didSet {
      todoTableView.reloadData()
    }
  }

  @IBAction func todoEntered(sender: Any) {
    guard todoTextField.stringValue != "" else { return }
    store.dispatch(action: AddTodo(text: todoTextField.stringValue))
    todoTextField.stringValue = ""
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    todoTableView.register(NSNib(nibNamed: "TodoCell", bundle: nil), forIdentifier: "TodoCell")
    store.connect(component: self)
  }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return state.todos.count
  }

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 52
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let todo = state.todos[row]

    let view = (tableView.make(withIdentifier: "TodoCell", owner: nil) as! TodoCell)
    view.checkButton.state = todo.isCompleted ? NSOnState : NSOffState
    view.todoLabel.stringValue = todo.title
    view.index = row
    return view
  }
}


class TodoCell: NSView {

  @IBOutlet var todoLabel: NSTextField!
  @IBOutlet var checkButton: NSButton!
  var index: Int = 0

  @IBAction func buttonTapped(_ sender: Any) {
    store.dispatch(action: ToggleTodo(index: index))
  }

}

