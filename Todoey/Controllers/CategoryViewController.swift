//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Santos, Rafael Costa on 12/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArr: [CategoryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
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
                let category = CategoryItem(context: self.context)
                category.name = value
                self.categoryArr.append(category)
                self.saveData()
            }
        }))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryArr[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? TodoListViewController
        if let vc = destinationVC,
           let indexPath = tableView.indexPathForSelectedRow {
            vc.selectedCategory = categoryArr[indexPath.row]
        }
    }
}

// MARK: - CoreData Funcs
extension CategoryViewController {
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest()) {
        do {
            categoryArr = try context.fetch(request)
        } catch {
            print("Error loading data: \(error)")
        }
        tableView.reloadData()
    }
}
