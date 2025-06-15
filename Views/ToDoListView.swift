//
//  ToDoListView.swift
//  ToDoList
//
//  Updated 6/15/25 – folders reorder + AI FAB
//

import SwiftUI
import FirebaseFirestore

// MARK: – Root
struct ToDoListView: View {
    // Firestore + VM
    @StateObject private var vm: ToDoListViewViewModel
    @FirestoreQuery private var items: [ToDoListItem]

    // UI state
    @State private var expanded: Set<String> = []
    @State private var ordered:  [String]    = []
    @State private var showingAIPicker = false
    @Environment(\.editMode) private var editMode

    private let uid: String
    init(userId: String) {
        uid = userId
        _items = FirestoreQuery(collectionPath: "users/\(userId)/todos")
        _vm    = StateObject(wrappedValue: .init(userId: userId))
    }

    private var grouped: [String: [ToDoListItem]] {
        Dictionary(grouping: items) { $0.category }
    }

    // ───────── body ─────────
    var body: some View {
        ZStack {
            // MAIN NAV
            NavigationView {
                List {
                    // one row per category (re-orderable)
                    ForEach(ordered, id: \.self) { cat in
                        CategoryRow(
                            category: cat,
                            items: grouped[cat] ?? [],
                            expanded: $expanded,
                            tint: color(for: cat)
                        ) { id in
                            vm.delete(id: id)
                        }
                    }
                    .onMove { ordered.move(fromOffsets: $0, toOffset: $1) }
                }
                .listRowSpacing(6)               // gap between folders
                .id(ordered.joined())            // refresh after drag
                .sectionSpacing(12)              // top breathing room (iOS 17)
                .navigationTitle("To-Do List")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { vm.showingNewItemView = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $vm.showingNewItemView) {
                    NewItemView(newItemPresented: $vm.showingNewItemView)
                }
                .onAppear { syncOrder() }
                .onChange(of: items.map(\.category)) { _, _ in syncOrder() }
                .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 6) }
            }

            // FLOATING AI BUTTON
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AIButton(
                        action: { showingAIPicker = true },
                        systemImage: "sparkles"
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 34)   // above home indicator
                }
            }
        }
        .sheet(isPresented: $showingAIPicker) {
            // Phase-2 placeholder
            Text("Folder picker coming soon")
                .font(.title)
                .presentationDetents([.medium])
        }
    }

    // MARK: – helpers
    private func syncOrder() {
        let fresh = grouped.keys.sorted()
        ordered = ordered.filter(fresh.contains)
               + fresh.filter { !ordered.contains($0) }
    }

    private func color(for name: String) -> Color {
        switch name.lowercased() {
        case "school":   return .blue
        case "work":     return .orange
        case "personal": return .green
        case "shopping": return .pink
        default:         return .gray.opacity(0.6)
        }
    }
}

// MARK: – CategoryRow
private struct CategoryRow: View {
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

// MARK: – View spacing helper (iOS 16 fallback)
private extension View {
    @ViewBuilder func sectionSpacing(_ v: CGFloat) -> some View {
        if #available(iOS 17, *) { self.listSectionSpacing(.custom(v)) } else { self }
    }
}

