//
//  SettingView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/6/13.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var soundController: SoundController
    @EnvironmentObject var appearanceObject: AppearanceObject
    let useCouponNotification = NotificationCenter.default.publisher(for: Notification.Name("use coupon"))
    @State private var couponCode: String = ""
    @State private var showAlert = false
    @State private var alertMsg = ""
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            Button(action: {
                soundController.playPoyoMusic()
                gameObject.currentState = .home
            }){
                Image("previous")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                
            }
            .offset(x: -UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
            VStack{
                HStack{
                    Button(action: {
                        soundController.playPoyoMusic()
                        soundController.toogleSound()
                    }, label: {
                        Image(soundController.isStopSound ? "cancel" : "checked")
                            .resizable()
                            .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                    })
                    Text("sound effect")
                    Button(action: {
                        soundController.playPoyoMusic()
                        soundController.toogleBackground()
                    }, label: {
                        Image(soundController.isStopBackground ? "cancel" : "checked")
                            .resizable()
                            .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                    })
                    Text("background music")
                }
                HStack{
                    TextField("couponCode", text: $couponCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: UIScreen.screenWidth / 3.5)
                    Button(action: {
                        soundController.playPoyoMusic()
                        firestoreData.useCoupon(code: couponCode)
                    }, label: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 247/255, green: 202/255, blue: 205/255))
                            .frame(width: UIScreen.screenHeight / 3.5, height: UIScreen.screenHeight / 9, alignment: .center)
                            .overlay(
                                Text("use coupon")
                            )
                    })
                }
                
                Button(action: {
                    do{
                        try firestoreData.logOut()
                        for i in 0..<9{
                            appearanceObject.chooseIndex[i] = 0
                        }
                        gameObject.currentState = .login
                        gameObject.userImg = Image("defaultImg")
                        firestoreData.initUser()
                    } catch{
                        print(error)
                    }
                }, label:{
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(red: 247/255, green: 202/255, blue: 205/255))
                        .frame(width: UIScreen.screenHeight / 3.5, height: UIScreen.screenHeight / 9, alignment: .center)
                        .overlay(
                            Text("Log out")
                        )
                })
            }
            
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            return Alert(title: Text(alertMsg))
        }
        .onReceive(useCouponNotification, perform: { _ in
            if (firestoreData.getCoupon == false && firestoreData.hadCoupon == true){
                alertMsg = "Already used the coupon code."
            }
            else if (firestoreData.getCoupon == false){
                alertMsg = "The coupon code does'n exist."
            }
            else if(firestoreData.getCoupon == true){
                alertMsg = "You get a heart!"
            }
            showAlert = true
            firestoreData.hadCoupon = false
            firestoreData.getCoupon = false
        })
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
