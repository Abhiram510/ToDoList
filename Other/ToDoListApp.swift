//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//
import FirebaseCore
import SwiftUI

@main
struct ToDoListApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
