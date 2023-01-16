//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Santos, Rafael Costa on 12/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "New Category", message: "Add new category", preferredStyle: .alert)
        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "Create New Item"
            textField = alertTextfield
        }
        alert.addAction(.init(title: "Confirm", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            if let value = textField.text {
                let category = Category()
                category.name = value
                self.save(category: category)
            }
        }))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        if let categorie = categories?[indexPath.row] {
            cell.textLabel?.text = categorie.name
            cell.textLabel?.textAlignment = .left
        } else {
            cell.textLabel?.text = "No Categories Yet"
            cell.textLabel?.textAlignment = .center
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? TodoListViewController
        if let vc = destinationVC,
           let indexPath = tableView.indexPathForSelectedRow,
           let categories = categories?[indexPath.row] {
            vc.selectedCategory = categories
        }
    }
}

// MARK: - Realm Funcs
extension CategoryViewController {
    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving data: \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
}
