//
//  LoginView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/22.
//

import SwiftUI
import FirebaseAuth
import FacebookLogin
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LoginView: View {
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
                Button(NSLocalizedString("Sign In", comment: "")){
                    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                        
                        guard let user = result?.user, error == nil else{
                            errorMessage = error!.localizedDescription
                            showAlert = true
                            print(error?.localizedDescription)
                            return
                        }
                        
                        if let user = Auth.auth().currentUser{
                            gameObject.currentState = .loading
                        }
                        else{
                            print("not login")
                        }
                        
                    }
                    
                }
                Button(NSLocalizedString("Create an account", comment: "")){
                    gameObject.currentState = .register
                }
                Button(NSLocalizedString("Log in with Facebook", comment: "")){
                    let manager = LoginManager()
                    manager.logIn(permissions: [.email, .publicProfile]){ (result) in
                        if case LoginResult.success(granted: _, declined: _, token: _) = result {
                            print("Facebook login ok")
                            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                            
                            Auth.auth().signIn(with: credential){
                                (result, error) in
                                guard error == nil else{
                                    errorMessage = error!.localizedDescription
                                    showAlert = true
                                    print(error?.localizedDescription)
                                    return
                                }
                                print("fb login firebase ok")
                                getFbEmail()
                            }
                        }
                        else{
                            print("Facebook login fail")
                        }
                        
                    }
                    
                }
                
            }
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            return Alert(title: Text(errorMessage))
        }
    }
    
    func getFbEmail(){
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"])
        
        request.start{ (response, result, error) in
            if let result = result as? [String: String]{
                firestoreData.user.userInfo.email = result["email"] ?? ""
                firestoreData.user.userInfo.method = "facebook"
                isDupUser()
            }
        }
    }
    
    func isDupUser(){
        let db = Firestore.firestore()
        let email = firestoreData.user.userInfo.email
        let method = firestoreData.user.userInfo.method
        db.collection("users").whereField("email", isEqualTo: email).whereField("method", isEqualTo: method).getDocuments{ snapshot, error in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.compactMap{ snapshot in
                try? snapshot.data(as: User.self)
            }
            if(users.isEmpty){
                gameObject.currentState = .enterName
            }
            else{
                gameObject.currentState = .loading
            }
        }
    }
    
}

