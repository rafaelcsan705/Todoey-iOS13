//
//  TodoListViewController.swift
//  Todoey
//


import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    let searchBar = UISearchBar()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
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
                self.saveItem(titleForItem: value)
            }
        }))
        present(alert, animated: true)
    }
    
    func saveItem(titleForItem: String) {
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm.write({
                    let item = Item()
                    item.title = titleForItem
                    item.dateCreated = Date()
                    currentCategory.items.append(item)
                })
            } catch {
                print("Error saving new items, \(error)")
            }
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title")
        tableView.reloadData()
    }
}

// MARK: - TableView Methods
extension TodoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse or create a cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! SwipeTableViewCell
        if let item = todoItems?[indexPath.row] {
            cell.delegate = self
            cell.textLabel?.text = item.title
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = item.isSelected ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Yet"
            cell.textLabel?.textAlignment = .center
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    realm.delete(item)
//                    item.isSelected.toggle()
                })
            } catch {
                print("Error updating item, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SwipeCellKit Delegate
extension TodoListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            print("Delete!")
        }
        deleteAction.image = UIImage(named: "deleteIcon")
        return [deleteAction]
    }
}

// MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: false)
        }
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
