//
//  TodoListViewController.swift
//  Todoey
//


import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Folder: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
}

// MARK: - Funcs
extension TodoListViewController {

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item",
                                      message: "Now you can add a new item on list.",
                                      preferredStyle: .alert)
        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "Create New Item"
            
            //Copy alertTextField in local variable to use in current block of code
            textField = alertTextfield
        }
        alert.addAction(.init(title: "Add Item", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let value = textField.text {
                let item = Item(context: self.context)
                item.title = value
                item.isSelected = false
                self.itemArray.append(item)
                self.saveItems()
            }
        }))
        present(alert, animated: true)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving ItemArray: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        do {
            if let arr = try context.fetch(.init(entityName: "Item")) as? [Item] {
                itemArray = arr
            }
            tableView.reloadData()
        } catch {
            print("Error decoding ItemArray: \(error)")
        }
    }
}

// MARK: - TableView Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse or create a cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isSelected ? .checkmark : .none
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].isSelected.toggle()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
