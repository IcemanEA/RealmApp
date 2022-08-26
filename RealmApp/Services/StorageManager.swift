//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    // MARK: - Task List
    func insert(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func update(_ taskList: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskList])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }
    
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }

    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Tasks
    func insert(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        write {
            let task = Task(value: [task, note])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    func update(_ task: Task, newName name: String, andNote note: String, completion: (Task) -> Void) {
        write {
            task.name = name
            task.note = note            
            completion(task)
        }
    }
        
    func delete(_ task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func done(_ task: Task) {
        write {
            task.setValue(true, forKey: "isComplete")
        }
    }
    
    func unDone(_ task: Task) {
        write {
            task.setValue(false, forKey: "isComplete")
        }
    }
    
    
    // MARK: - write
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
