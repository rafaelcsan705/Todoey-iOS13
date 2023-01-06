//
//  TodoListViewController.swift
//  Todoey
//


import UIKit

class TodoListViewController: UITableViewController {
    
    let userDefauts = UserDefaults.standard
    var itemArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let items = userDefauts.value(forKey: "TodoListArray") as? [String] {
            itemArray = items
        }
    }
}

// MARK: - Funcs
extension TodoListViewController {
    func checkAccessoryTypeOfTableViewCell(cell: UITableViewCell?) {
        guard let tableViewCell = cell else { return }
        let checkmarkAccessoryType = tableViewCell.accessoryType == .checkmark
        tableViewCell.accessoryType = checkmarkAccessoryType ? .none : .checkmark
    }
    
    
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
                self.itemArray.append(value)
                self.userDefauts.set(self.itemArray, forKey: "TodoListArray")
                self.tableView.reloadData()
            }
        }))
        present(alert, animated: true)
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
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkAccessoryTypeOfTableViewCell(cell: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
