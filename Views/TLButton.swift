//
//  TLButton.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import SwiftUI

struct TLButton: View {
    
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            // Action
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
        
    }
}

#Preview {
    TLButton(title: "Value", background: .pink){
        // Action
    }
    
}
