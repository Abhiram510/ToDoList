//
//  AIButtonView.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/15/25.
//

import SwiftUI

struct AIButton: View {
    let action: () -> Void
    let systemImage: String
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                        .shadow(radius: 6, y: 3)
                )
        }
        .accessibilityLabel(Text("AI Assistant"))
    }
}
