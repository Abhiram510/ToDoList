//
//  LoginView.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "SmartPlanr",
                           subtitle: "",
                           angle: 24,
                           background: .pink)
                
                
                
                
                // Login Form
                
                Form {
                    
                    if !viewModel.errorMessage.isEmpty{
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }
                    
                    
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())
                    
                    TLButton(
                        title: "Log in",
                        background: .blue) {
                        // Attempt Log in
                            viewModel.login()
                    }
                        .padding()
                    
                }
                .offset(y: -10)
                
                // Create Account
                VStack {
                    Text("New around here?")
                    NavigationLink("Create An Account",
                    destination: RegisterView())
                }
                .padding(.bottom, 50)
                
                Spacer()
                
                
            }
        }
    }
}

#Preview {
    LoginView()
}
