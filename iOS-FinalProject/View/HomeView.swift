//
//  HomeView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/16.
//

import SwiftUI
import FacebookLogin
import FirebaseAuth
import AVFoundation

struct HomeView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var soundController: SoundController
    let rewardedAdController = RewardedAdController()
    @State private var showAlert = false
    @State private var alertMsg = ""
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            Button(action:{
                soundController.playPoyoMusic()
                gameObject.currentState = .setting
            }, label:{
                Image("setting")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
            })
            .offset(x: UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
            HStack{
                Image("memo")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*1, height: UIScreen.screenHeight*1)
                    .onTapGesture(count: 3, perform:{
                        rewardedAdController.loadAd()
                    })
                    .overlay(
                        Button(action:{
                            soundController.playPoyoMusic()
                            gameObject.currentState = .profile
                        }, label:{
                            gameObject.userImg
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.screenHeight * 0.4, height: UIScreen.screenHeight * 0.4)
                        })
                        
                    )
                .offset(x: -UIScreen.screenWidth*0.1)
                
                VStack{
                    HeartsView(heartsNum: firestoreData.user.heartsNum, timerCount: firestoreData.user.timerCount)
                        .onTapGesture(count: 5, perform:{
                            rewardedAdController.showAd()
                        })
                    
                    Button(action: {
                        rewardedAdController.loadAd()
                        if(firestoreData.user.heartsNum == 0){
                            alertMsg = "Whether to watch the ad to get a heart?"
                            showAlert = true
                        }
                        else{
                            soundController.playPoyoMusic()
                            gameObject.currentState = .intoRoom
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 247/255, green: 202/255, blue: 205/255))
                            .frame(width: UIScreen.screenHeight / 3.5, height: UIScreen.screenHeight / 9, alignment: .center)
                            .overlay(
                                Text("Enter to room")
                            )
                    })
                    
                }
                .offset(x: -UIScreen.screenWidth*0.1)
            }
            
        }
        .alert(isPresented: $showAlert){
            var alert = Alert(title: Text("You don't have heart to play.ＱＱ") , message: Text(alertMsg), primaryButton: .default(Text("Yes"), action: {
                rewardedAdController.showAd()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    firestoreData.addHeartsNum()
                }
            }), secondaryButton: .default(Text("No"), action: {
                print("才不要哩")
            }))
            
            return alert
        }
    }
    
    
}

struct HeartsView: View{
    var heartsNum: Int
    var timerCount: Int
    var body: some View{
        HStack{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 255/255, green: 255/255, blue: 232/255))
                .frame(width: UIScreen.screenWidth * 0.3, height: UIScreen.screenHeight / 9, alignment: .center)
                .overlay(
                    HStack(spacing: 4){
                        ForEach(0..<5){ index in
                            if(index < heartsNum){
                                Image("heart")
                                    .resizable()
                                    .frame(width: UIScreen.screenHeight / 9, height: UIScreen.screenHeight / 9)
                            }
                            else{
                                Image("emptyHeart")
                                    .resizable()
                                    .frame(width: UIScreen.screenHeight / 9, height: UIScreen.screenHeight / 9)
                            }
                            
                        }
                    }
                )
            Text("0\((300 - timerCount)/60) : \(((300 - timerCount)%60)/10)\(((300 - timerCount)%60)%10)")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
