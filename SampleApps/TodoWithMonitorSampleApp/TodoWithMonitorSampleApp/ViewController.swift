//
//  ViewController.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit
import Suas

class ViewController: UIViewController, Component {

  @IBOutlet weak var todoTextField: UITextField!
  @IBOutlet weak var addTodoButton: UIButton!
  @IBOutlet weak var todoTableView: UITableView!

  var state: TodoState = store.state.valueOrFail(forKeyOfType: TodoState.self) {
    didSet {
      todoTableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    store.connect(component: self)
  }

  @IBAction func addTodoTapped(_ sender: Any) {
    store.dispatch(action: AddTodo(text: todoTextField.text ?? ""))
    todoTextField.text = ""
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

    let post = state.todos[indexPath.row]
    cell.textLabel?.text = post.title
    cell.textLabel?.textColor = post.isCompleted ? UIColor.gray : UIColor.black

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return state.todos.count
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    store.dispatch(action: ToggleTodo(index: indexPath.row))
  }
}
