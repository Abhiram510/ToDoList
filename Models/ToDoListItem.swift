//
//  ToDoListItem.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import Foundation

struct ToDoListItem: Codable, Identifiable {
    let id: String
    let title: String
    let dueDate: TimeInterval
    let createdDate: TimeInterval
    var isDone: Bool
    let category: String
    
    init(id: String, title: String, dueDate: TimeInterval, createdDate: TimeInterval, isDone: Bool, category: String = "Uncategorized") {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.createdDate = createdDate
        self.isDone = isDone
        self.category = category
    }
    
    mutating func setDone(_ state: Bool) {
        isDone = state
    }
}

