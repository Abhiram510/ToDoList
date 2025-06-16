//
//  AIPlannerViewModel.swift
//  ToDoList
//
//  Generates a markdown study / work plan with Google Gemini.
//  – Primary model  : gemini-1.5-flash-latest  (larger free quota)
//  – Fallback model : gemini-1.5-pro-latest
//

import Foundation

@MainActor
final class AIPlannerViewModel: ObservableObject {

    // ─────────────────────────────────────────────────────────── Published
    @Published var markdown: String?
    @Published var isLoading = false
    @Published var error: String?

    // ─────────────────────────────────────────────────────────── Constants
    private let primaryModel  = "gemini-1.5-flash-latest"   // higher free quota
    private let backupModel   = "gemini-1.5-pro-latest"     // use if flash fails

    private var apiKey: String {
        ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    }

    // MARK: – entry point
    func makePlan(for categories: Set<String>, from tasks: [ToDoListItem]) async {
        #if DEBUG
        dbgCompare(tasks: tasks, chosenRaw: categories)
        #endif

        markdown = nil; error = nil; isLoading = true

        // 1️⃣ filter incomplete tasks that match the chosen folders
        let chosen = Set(
            categories.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        )
        let todo = tasks.filter {
            chosen.contains(
                $0.category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            ) && !$0.isDone
        }

        guard !todo.isEmpty else {
            error = "No incomplete tasks in those folders."
            isLoading = false; return
        }

        // 2️⃣ build markdown bullet list
        let bullets = todo.map { t -> String in
            let due = Date(timeIntervalSince1970: t.dueDate)
                .formatted(date: .abbreviated, time: .omitted)
            return "- [ ] \(t.title) (due \(due))"
        }.joined(separator: "\n")

        let prompt = """
        You are a study coach. Create an optimal daily schedule so the user
        finishes these tasks before their due dates.

        • Return the schedule as Markdown bullet lines (no table).  
        • Use one bullet per time-block.  
        • After the list add a short rationale.

        Tasks:
        \(bullets)
        """


        // 3️⃣ call Gemini – try Flash first, fall back to Pro if needed
        do {
            do {
                markdown = try await callGemini(model: primaryModel, prompt: prompt)
            } catch {
                // retry once with the backup model
                markdown = try await callGemini(model: backupModel, prompt: prompt)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: – single-call helper
    @discardableResult
    private func callGemini(model: String, prompt: String) async throws -> String {
        let url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/"
          + "\(model):generateContent?key=\(apiKey)")!

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)

        #if DEBUG
        if let http = response as? HTTPURLResponse {
            print("🟥 Gemini (\(model)) status:", http.statusCode)
        }
        print("🟥 Raw JSON ⇢\n", String(data: data, encoding: .utf8) ?? "<nil>")
        #endif

        return try extractMarkdown(from: data)  // may throw with clear message
    }

    // MARK: – minimal decoding (handles success *and* error JSON)
    private func extractMarkdown(from data: Data) throws -> String {
        struct Success: Decodable {
            struct Candidate: Decodable {
                struct Part: Decodable { let text: String? }
                struct Content: Decodable { let parts: [Part] }
                let content: Content
            }
            let candidates: [Candidate]
        }
        struct Failure: Decodable {
            struct Err: Decodable { let message: String }
            let error: Err
        }

        if let ok = try? JSONDecoder().decode(Success.self, from: data),
           let text = ok.candidates.first?.content.parts.first?.text {
            return text
        }
        if let bad = try? JSONDecoder().decode(Failure.self, from: data) {
            throw NSError(domain: "Gemini", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: bad.error.message])
        }
        throw NSError(domain: "Gemini", code: -2,
                      userInfo: [NSLocalizedDescriptionKey: "Unknown response format"])
    }
}

// ─────────────────────────────────────────────────────────── DEBUG helper
#if DEBUG
func dbgCompare(tasks: [ToDoListItem],
                chosenRaw: Set<String>,
                file: StaticString = #file, line: UInt = #line)
{
    let chosen = Set(chosenRaw.map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    })
    print("🟢 DEBUG \(file):\(line)")
    print("   chosenRaw   =", Array(chosenRaw))
    print("   chosenNorm  =", Array(chosen))
    for t in tasks {
        let norm = t.category
              .trimmingCharacters(in: .whitespacesAndNewlines)
              .lowercased()
        let flag = chosen.contains(norm) ? "✔︎" : "✘"
        print(" \(flag) «\(t.category)»  → norm «\(norm)»")
    }
    print("----------------------------")
}
#endif
