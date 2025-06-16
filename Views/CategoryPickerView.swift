//
//  CategoryPickerView.swift
//  ToDoList
//

import SwiftUI

// MARK: – Row with checkbox on the right
private struct CategorySelectRow: View {
    let title: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack {
                Text(title.capitalized)
                Spacer()
                Image(systemName: isSelected
                                ? "checkmark.square.fill"
                                : "square")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.accentColor)
            }
        }
        .buttonStyle(.plain)          // keep native row feel
    }
}

// MARK: – Main picker sheet
struct CategoryPickerView: View {
    /// Folders to show (inject from ToDoListView)
    let categories: [String]
    /// Called when user taps Next
    let onConfirm: (Set<String>) -> Void

    @State private var selection = Set<String>()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { cat in
                    CategorySelectRow(
                        title: cat,
                        isSelected: Binding(
                            get: { selection.contains(cat) },
                            set: { value in
                                if value { selection.insert(cat) }
                                else     { selection.remove(cat) }
                            }
                        )
                    )
                }
            }
            .navigationTitle("Choose folders")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next") {
                        onConfirm(selection)
                        dismiss()
                    }
                    .disabled(selection.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#if DEBUG
#Preview {
    CategoryPickerView(
        categories: ["other", "personal", "school", "work"],
        onConfirm: { print($0) }
    )
}
#endif
