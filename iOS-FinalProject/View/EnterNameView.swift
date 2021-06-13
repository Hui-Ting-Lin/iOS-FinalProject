//
//  EnterNameView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

struct EnterNameView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @State private var name = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var uid = ""
    
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            HStack{
                Text("Enter your name")
                TextField("name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: UIScreen.screenWidth*0.5)
                Button("enter"){
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges(completion: {
                        error in
                        guard error == nil else{
                            errorMessage = error!.localizedDescription
                            showAlert = true
                            print(error?.localizedDescription)
                            return
                        }
                    })
                    if let user = Auth.auth().currentUser{
                        uid = user.uid
                    }
                    firestoreData.creatUser(method: gameObject.registerMethod, name: name, registerTime: getTime(), uid: uid)
                    
                    gameObject.currentState = .home
                    
                }
                
            }
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            return Alert(title: Text(errorMessage))
        }
    }
    
    
    func getTime() -> String{
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_us")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: now)
    }
}


