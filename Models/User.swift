//
//  User.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import Foundation


struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined : TimeInterval
}
