//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Santos, Rafael Costa on 17/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import SwipeCellKit
import RealmSwift

class SwipeTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleTableViewCell()
    }
    
    func updateModel(at indexPath: IndexPath) {
        // Function to be overrided
    }
    
    func styleTableViewCell() {
        tableView.rowHeight = 80.0
    }
}

// MARK: - TableView and SwipeCellKit Functions
extension SwipeTableViewController: SwipeTableViewCellDelegate {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            guard let self = self else { return}
            self.updateModel(at: indexPath)
        }
        
        if let deleteIcon = UIImage(named: "delete-icon") {
            deleteAction.image = deleteIcon.resizeImage(targetSize: CGSize(width: 20, height: 20))
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
}

// MARK: - Realm Function
extension SwipeTableViewController {
    func save(_ object: Object) {
        do {
            try realm.write({
                realm.add(object)
            })
        } catch {
            print("Error saving data: \(error)")
        }
        tableView.reloadData()
    }
    
    func delete(_ object: Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error saving data: \(error)")
        }
    }
}

