//
//  TaskList.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

enum ResultType {
    case isEmpty
    case inWork(Int)
    case allDone
}

class TaskList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}

extension TaskList {
    func getResultType() -> ResultType {
        if tasks.count == 0 {
            return .isEmpty
        }
        
        var onGoing = 0
        for task in tasks {
            if !task.isComplete {
                onGoing += 1
            }
        }
        if onGoing > 0 {
            return .inWork(onGoing)
        } else {
            return .allDone
        }
    }
}
