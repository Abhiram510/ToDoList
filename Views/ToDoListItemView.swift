//
//  ToDoListItemView.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import SwiftUI

struct ToDoListItemView: View {
    @StateObject var viewModel = ToDoListItemViewViewModel()
    let item: ToDoListItem
    
    // Color Coding function
    
    func colorForCategory(_ category: String) -> Color {
        switch category {
        case "School": return .blue
        case "Work": return .green
        case "Personal": return .purple
        case "Other": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.body)
                    
                Text("\(Date(timeIntervalSince1970: item.dueDate).formatted(date: .abbreviated, time:. shortened))")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                
                Text(item.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForCategory(item.category).opacity(0.2))
                    .foregroundColor(colorForCategory(item.category))
                    .cornerRadius(10)
            }
            
            Spacer()
            
            Button {
                viewModel.toggleIsDone(item: item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color.blue)
            }
        }
    }
}

#Preview {
    ToDoListItemView(item: .init(id: "123", title: "Get milk", dueDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: true, category: "Personal"))
}
