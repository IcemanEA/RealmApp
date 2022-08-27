//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    // MARK: - public properties
    var taskList: TaskList!
    
    // MARK: - private properties
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    // MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        updateTasksLists()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        let task: Task
        
        if indexPath.section == 0 {
            task = currentTasks[indexPath.row]
            
            let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self]  _, _, isDone in
                StorageManager.shared.done(task)
                
                tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
                updateTasksLists()
                isDone(true)
            }
            doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            actions.append(doneAction)
        } else {
            task = completedTasks[indexPath.row]
            
            let unDoneAction = UIContextualAction(style: .normal, title: "UnDone") { [unowned self] _, _, isDone in
                StorageManager.shared.done(task)
                
                tableView.moveRow(at: indexPath, to: IndexPath(row: currentTasks.count - 1, section: 0))
                updateTasksLists()
                isDone(true)
            }
            actions.append(unDoneAction)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        editAction.backgroundColor = .orange
        actions.append(editAction)

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        actions.append(deleteAction)
                
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // MARK: - Private methods
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func updateTasksLists() {
        currentTasks = taskList.tasks
            .filter("isComplete = false")
            .sorted(byKeyPath: "date", ascending: true)
        completedTasks = taskList.tasks
            .filter("isComplete = true")
            .sorted(byKeyPath: "date", ascending: false)
    }

}

// MARK: - Alert methods
extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { [weak self] taskTitle, note in
            if let task = task, let completion = completion {
                self?.update(task, newName: taskTitle, andNote: note, completion: completion)
            } else {
                self?.insert(task: taskTitle, withNote: note)
            }
        }
        
        present(alert, animated: true)
    }

    private func update(_ task: Task, newName name: String, andNote note: String, completion: () -> Void)  {
        StorageManager.shared.update(task, newName: name, andNote: note)
        completion()
    }
    
    private func insert(task: String, withNote note: String) {
        StorageManager.shared.insert(task, withNote: note, to: taskList) { task in
            let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
