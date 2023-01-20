//
//  TodoListViewController.swift
//  Todoey
//


import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
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
    
    override func updateModel(at indexPath: IndexPath) {
        guard let item = selectedCategory?.items[indexPath.row] else { return }
        self.delete(item)
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
                self.save(title: value)
            }
        }))
        present(alert, animated: true)
    }
    
    func save(title: String) {
        if let currentCategory = self.selectedCategory {
            do {
                try realm.write({
                    let item = Item()
                    item.title = title
                    item.dateCreated = Date()
                    currentCategory.items.append(item)
                })
            } catch {
                print("Error saving data: \(error)")
            }
        }
        
        tableView.reloadData()
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = item.isSelected ? .checkmark : .none
            
            if let todoItemsCount = todoItems?.count,
               let backgroundStr = selectedCategory?.backgroundColor,
               let color = UIColor(hexString: backgroundStr) {
                let backgroundPercentage: CGFloat = CGFloat(indexPath.row) / CGFloat(todoItemsCount)
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.backgroundColor = color.darken(byPercentage: backgroundPercentage)
                
            }
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
                    //                    realm.delete(item)
                    item.isSelected.toggle()
                })
            } catch {
                print("Error updating item, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
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
