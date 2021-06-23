//
//  RegisterView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift

struct RegisterView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            
            VStack{
                TextField("email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: UIScreen.screenWidth*0.5)
                TextField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: UIScreen.screenWidth*0.5)
                
                Button(NSLocalizedString("Sign Up", comment: "")){
                    
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        
                        guard let user = result?.user, error == nil else{
                            errorMessage = error!.localizedDescription
                            showAlert = true
                            
                            print(error?.localizedDescription)
                            return
                        }
                        firestoreData.user.userInfo.email = email
                        firestoreData.user.userInfo.password = password
                        gameObject.registerMethod = "email"
                        gameObject.currentState = .enterName
                    }
                    
                }
                
                Button(NSLocalizedString("Already have an account", comment: "")){
                    gameObject.currentState = .login
                }
            }
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            return Alert(title: Text(errorMessage))
        }
    }
    
    
    
    
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
