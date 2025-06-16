//
//  AIPlannerView.swift
//  ToDoList
//

import SwiftUI

struct AIPlannerView: View {
    @StateObject private var vm = AIPlannerViewModel()

    let chosenCategories: Set<String>
    let allTasks: [ToDoListItem]

    // 👈 add this
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let md = vm.markdown {
                ScrollView {
                    Text(AttributedString(md))                // nicer Markdown
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                }

            } else if vm.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Generating your study plan…")
                }

            } else if vm.error != nil {
                VStack(spacing: 16) {
                    Text(vm.error!)
                        .foregroundColor(.red)

                    // 👉 send them back to the picker
                    Button("Choose Folders Again") {
                        dismiss()          // close this sheet
                    }
                    .buttonStyle(.borderedProminent)
                }

            } else {
                VStack(spacing: 12) {                       // unlikely fallback
                    ProgressView()
                    Text("Preparing…")
                }
            }
        }
        .navigationTitle("AI Study Plan")
        .task {                                             // fire on first show
            await vm.makePlan(for: chosenCategories, from: allTasks)
        }
        .presentationDetents([.large])
    }
}


#if DEBUG
#Preview {
    AIPlannerView(chosenCategories: ["school", "work"], allTasks: [])
}
#endif
