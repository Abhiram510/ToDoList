import SwiftUI

/// Collapsible “folder” row for one category
struct CategoryRowView: View {
    let category: String
    let items: [ToDoListItem]
    @Binding var expanded: Set<String>
    let tint: Color
    let deleteAction: (String) -> Void

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expanded.contains(category) },
                set: { open in
                    if open { expanded.insert(category) }
                    else    { expanded.remove(category) }
                })
        ) {
            ForEach(items) { item in
                ToDoListItemView(item: item)
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteAction(item.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        } label: {
            Text(category.capitalized)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(tint)
                )
        }
    }
}

#if DEBUG
#Preview {
    CategoryRowView(
        category: "school",
        items: [],
        expanded: .constant([]),
        tint: .blue,
        deleteAction: { _ in }
    )
    .padding()
}
#endif
