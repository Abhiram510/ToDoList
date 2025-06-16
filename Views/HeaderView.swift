//
//  HeaderView.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String
    let angle: Double
    let background: Color
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(background)
                .rotationEffect(Angle(degrees: angle))
                
            
            VStack {
                Text(title)
                    .font(.system(size : 50))
                    .foregroundColor(Color.white)
                    .bold()
                Text (subtitle)
                    .font(.system(size : 30))
                    .foregroundColor(Color.white)
            }
            .padding(.top, 40)
        }
        .frame(width: UIScreen.main.bounds.width * 3, height: 390)
        .offset(y: -120)
    }
}

#Preview {
    HeaderView(title : "Title",
               subtitle: "Subtitle", angle: 15, background: .blue)
}
