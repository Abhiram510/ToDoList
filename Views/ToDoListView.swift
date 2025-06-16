//
//  ToDoListView.swift
//  ToDoList
//

import SwiftUI
import FirebaseFirestore

struct ToDoListView: View {
    // Firestore + VM
    @StateObject private var vm: ToDoListViewViewModel
    @FirestoreQuery private var items: [ToDoListItem]

    // UI state
    @State private var expanded = Set<String>()
    @State private var ordered  = [String]()
    @State private var showingAIPicker = false
    @State private var aiSelection: Set<String>?
    @Environment(\.editMode) private var editMode

    private let uid: String
    init(userId: String) {
        uid = userId
        _items = FirestoreQuery(collectionPath: "users/\(userId)/todos")
        _vm    = StateObject(wrappedValue: .init(userId: userId))
    }

    private var grouped: [String:[ToDoListItem]] {
        Dictionary(grouping: items) { $0.category }
    }

    // ───────── body ─────────
    var body: some View {
        ZStack {
            // MAIN NAV
            NavigationView {
                List {
                    ForEach(ordered, id: \.self) { cat in
                        CategoryRowView(
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
                .listRowSpacing(6)
                .id(ordered.joined())
                .sectionSpacing(12)
                .navigationTitle("Tasks")
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
                    AIButton(action: { showingAIPicker = true },
                             systemImage: "sparkles")
                        .padding(.trailing, 20)
                        .padding(.bottom, 34)
                }
            }
        }
        // 1st sheet: folder picker
        .sheet(isPresented: $showingAIPicker) {
            CategoryPickerView(categories: ordered) { picks in
                guard !picks.isEmpty else { return }
                aiSelection = picks          // ← THIS ALONE opens the planner
            }
        }




        // 2nd sheet: run the Gemini-powered planner
        // sheet appears whenever aiSelection holds a non-nil set
        .sheet(item: $aiSelection) { picks in
            NavigationStack {
                AIPlannerView(chosenCategories: picks,
                              allTasks: items)
            }
        }


    }

    // MARK: – helpers
    private func syncOrder() {
        let fresh = grouped.keys.sorted()
        ordered = ordered.filter(fresh.contains) + fresh.filter { !ordered.contains($0) }
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

// MARK: – CategoryRow unchanged (omitted for brevity)

// MARK: – View spacing helper
private extension View {
    @ViewBuilder func sectionSpacing(_ v: CGFloat) -> some View {
        if #available(iOS 17, *) { self.listSectionSpacing(.custom(v)) } else { self }
    }
}



extension Set: Identifiable where Element == String {
    public var id: String { self.sorted().joined(separator: "|") }
}


#if DEBUG
#Preview {
    ToDoListView(userId: "preview-user-id")
}
#endif

