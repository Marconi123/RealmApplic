//
//  TaskListTVC.swift
//  RealmApplic
//
//  Created by Владислав on 22.09.22.
//

import RealmSwift
import UIKit

final class TaskListTVC: UITableViewController {
    // MARK: - Properties
    
    var tasksLists: Results<TasksList>!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksLists = StorageManager.getAllTasksLists()
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func segmtentedControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasksLists[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.tasks.count.description
        cell.configure(with: task)
        return cell
    }

    // MARK: - Table view delegate
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green
         
        return swipeAction
    }
    
    // MARK: - Private func-s
    
    @objc private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesListTasks { [weak self] in
            self?.navigationItem.title = "alertForAddAndUpdatesListTasks"
            print("ListTasks")
        }
    }
    
    private func alertForAddAndUpdatesListTasks(_ tasksLists: TasksList? = nil,
                                                complition: @escaping () -> Void)
    {
        let title = tasksLists == nil ? "New list" : "Edit list"
        let message = "Please insert list name"
        let doneDuttonName = tasksLists == nil ? "Save" : "Update"
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: doneDuttonName, style: .default) { _ in
            guard let newListName = alertTextField.text, !newListName.isEmpty else {
                return
            }
            if let tasksLists = tasksLists {
                StorageManager.editList(tasksLists, newListName: newListName, complition: complition)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            alertTextField = textField
            if let listName = tasksLists {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "List name"
        }
        present(alert, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TaskTVC, let index = tableView.indexPathForSelectedRow {
            let list = tasksLists[index.row]
            destinationVC.currentList = list
        }
    }
}
