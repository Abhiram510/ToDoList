//
//  ProfileViewViewModel.swift
//  ToDoList
//
//  Created by Abhiram Batchali on 6/11/25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import Foundation

class ProfileViewViewModel: ObservableObject{
    init() {
        
    }
    
    @Published var user: User? = nil
    
    func fetchUser(){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.user = User(id: data["id"] as? String ?? "",
                                      name: data["name"] as? String ?? "",
                                      email: data["email"] as? String ?? "",
                                      joined: data["joined"] as? TimeInterval ?? 0)
                }
                
            }
    }
    
    
    func sendPasswordReset() {
        guard let email = Auth.auth().currentUser?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending reset email: \(error.localizedDescription)")
            } else {
                print("Password reset email sent")
            }
        }
    }
    
    func logOut(){
        do {
            try Auth.auth().signOut()
        } catch {
            print (error)
        }
    }
}
