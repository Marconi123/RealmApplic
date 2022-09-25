//
//  StorageManager.swift
//  RealmApplic
//
//  Created by Владислав on 22.09.22.
//

import Foundation
import RealmSwift

let realm = try! Realm()

enum StorageManager {
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deteleAll error")
        }
    }

    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self)
    }

    static func saveTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                realm.add(tasksList)
            }
        } catch {
            print("Save tasks list error: \(error)")
        }
    }

    static func deleteList(_ tasksLists: TasksList) {
        do {
            try realm.write {
                let tasks = tasksLists.tasks
                realm.delete(tasks)
                realm.delete(tasksLists)
            }
        } catch {
            print("Delete error: \(error)")
        }
    }

    static func makeAllDone(_ tasksList: TasksList) {
        do {
            try realm.write {
                tasksList.tasks.setValue(true, forKey: "isComplete")
            }
        } catch {
            print("Make all done error: \(error)")
        }
    }

    static func editList(_ tasksList: TasksList,
                         newListName: String,
                         complition: @escaping () -> Void)
    {
        do {
            try realm.write {
                tasksList.name = newListName
                complition()
            }
        } catch {
            print("Edit list error: \(error)")
        }
    }

    static func saveTask(_ tasksList: TasksList, task: Task) {
        do {
            try realm.write {
                tasksList.tasks.append(task)
            }
        } catch {
            print("Save task error: \(error)")
        }
    }

    static func editTask(_ task: Task, newNameTask: String, newNote: String) {
        do {
            try realm.write {
                task.name = newNameTask
                task.note = newNote
            }
        } catch {
            print("Edit task error: \(error)")
        }
    }

    static func deleteTask(_ task: Task) {
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Delete task error: \(error)")
        }
    }
    
    static func makeDone(_ task: Task) {
        do {
            try realm.write {
                task.isComplete.toggle()
            }
        } catch {
            print("Make done error: \(error)")
        }
    }
}
