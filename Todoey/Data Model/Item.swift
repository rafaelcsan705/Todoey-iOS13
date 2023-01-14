//
//  Item.swift
//  Todoey
//
//  Created by Santos, Rafael Costa on 13/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isSelected: Bool = false
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

