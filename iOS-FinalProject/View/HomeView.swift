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

import GoogleMobileAds

struct HomeView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var soundController: SoundController
    @State private var showAlert = false
    @State private var alertMsg = ""
    
    @State private var ad: GADRewardedAd?
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
                    .overlay(
                        Button(action:{
                            soundController.playPoyoMusic()
                            gameObject.currentState = .profile
                        }, label:{
                            Image(systemName: "defaultImg").data(url: URL(string: firestoreData.user.userInfo.image)!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.screenHeight * 0.4, height: UIScreen.screenHeight * 0.4)
                        })
                        
                    )
                    .offset(x: -UIScreen.screenWidth*0.1)
                
                VStack{
                    HeartsView(heartsNum: firestoreData.user.heartsNum, timerCount: firestoreData.user.timerCount)
                    Button(action: {
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
                                    .foregroundColor(.black)
                            )
                    })
                    
                }
                .offset(x: -UIScreen.screenWidth*0.1)
            }
            
        }
        .alert(isPresented: $showAlert){
            var alert = Alert(title: Text("You don't have heart to play.??????") , message: Text(alertMsg), primaryButton: .default(Text("Yes"), action: {
                showAd(){result in
                    switch result {
                    case true:
                        firestoreData.addHeartsNum()
                    case false:
                        print("failll")
                    }
                }
            }), secondaryButton: .default(Text("No"), action: {
                print("????????????")
            }))
            
            return alert
        }
        .onAppear{
            loadAd()
        }
    }
    
    func loadAd(){
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request){ad, error in
            if let error = error{
                print(error)
                return
            }
            self.ad = ad
        }
    }
    
    func showAd(completion: @escaping (Bool) -> Void){
        if let ad = ad,
           let controller = UIViewController.getLastPresentedViewController(){
            ad.present(fromRootViewController: controller){
                print("????????????")
                completion(true)
            }
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
                .frame(width: UIScreen.screenWidth * 0.32, height: UIScreen.screenHeight / 9, alignment: .center)
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
                .foregroundColor(.black)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
