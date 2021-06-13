//
//  LoadingView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/2.
//

import SwiftUI
import FirebaseAuth
import FacebookLogin
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LoadingView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            Image("map")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            VStack{
                ActivityIndicator()
                    .frame(width: 50, height: 50)
                Text("Loading.......")
            }
        }
        .onAppear{
            checkLogin()
        }
    }
    func checkLogin(){
        if let user = Auth.auth().currentUser{
            print("\(user.displayName) login")
            setUser(email: user.email!)
        }
        else{
            print("not login")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                gameObject.currentState = .login
            }
        }
    }
    
    func setUser(email: String){
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: firestoreData.getUid()).getDocuments{ snapshot, error in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.compactMap{ snapshot in
                try? snapshot.data(as: User.self)
            }
            if(!users.isEmpty){
                firestoreData.user = users[0]
                firestoreData.userDocId = firestoreData.user.id!
                if firestoreData.user.userInfo.image != "" {
                    gameObject.userImg = Image(systemName: "defaultImg").data(url: URL(string: firestoreData.user.userInfo.image)!)
                }
                else{
                    gameObject.userImg = Image("defaultImg")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    gameObject.currentState = .home
                }
            }
        }
        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
struct ActivityIndicator: View {
    
    @State private var isAnimating: Bool = false
    var body: some View {
        
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(0..<5) { index in
                Group {
                    MyCircle(isAnimating: isAnimating)
                        .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                .animation(
                    Animation
                        .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                        .repeatForever(autoreverses: false))
            }
            
        }.aspectRatio(1, contentMode: .fit)
        .onAppear {
            self.isAnimating = true
        }
    }
}

struct MyCircle: View{
    var isAnimating: Bool
    var body: some View{
        Circle()
            .fill(Color.white)
            .frame(width: UIScreen.screenHeight/90, height: UIScreen.screenHeight/90)
    }
}
