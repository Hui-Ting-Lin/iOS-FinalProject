//
//  ViewController.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/22.
//

import SwiftUI
import FirebaseAuth

struct ViewController: View {
    @StateObject var gameObject = GameObject()
    @StateObject var appearanceObject = AppearanceObject()
    @StateObject var firestoreData = FirestoreData()
    @StateObject var firestoreGame = FirestoreGame()
    @StateObject var soundController = SoundController()
    @Environment(\.scenePhase) private var scenePhase
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group{
            switch gameObject.currentState {
            case .login:
                LoginView().environmentObject(gameObject).environmentObject(firestoreData)
            case .register:
                RegisterView().environmentObject(gameObject).environmentObject(firestoreData)
            case .enterName:
                EnterNameView().environmentObject(gameObject).environmentObject(firestoreData)
            case .editAppearance:
                EditAppearanceView().environmentObject(gameObject).environmentObject(appearanceObject).environmentObject(firestoreData)
            case .start:
                StartView().environmentObject(gameObject).environmentObject(firestoreData)
                    .environmentObject(soundController)
            case .loading:
                LoadingView().environmentObject(gameObject).environmentObject(firestoreData)
            case .profile:
                ProfileView().environmentObject(gameObject).environmentObject(firestoreData)
            case .intoRoom:
                CreateRoomView().environmentObject(gameObject).environmentObject(firestoreData).environmentObject(soundController)
            case .gameRoom:
                RoomView().environmentObject(gameObject).environmentObject(firestoreData)
                    .environmentObject(firestoreGame).environmentObject(soundController)
            case .home:
                HomeView().environmentObject(gameObject).environmentObject(firestoreData).environmentObject(soundController)
            case .game:
                GameView().environmentObject(gameObject).environmentObject(firestoreData)
                    .environmentObject(firestoreGame).environmentObject(soundController)
            case .result:
                ResultView().environmentObject(gameObject).environmentObject(firestoreData)
                    .environmentObject(firestoreGame).environmentObject(soundController)
            case .setting:
                SettingView().environmentObject(gameObject).environmentObject(firestoreData).environmentObject(soundController).environmentObject(appearanceObject)
            
            }
            
        }
        .onReceive(timer) { time in
            if firestoreData.user.heartsNum < 5 && firestoreData.user.timerCount < 299{
                firestoreData.addTimerCount()
            } else if firestoreData.user.heartsNum < 5 && firestoreData.user.timerCount == 299{
                firestoreData.fillHeart()
            } else if firestoreData.user.heartsNum == 5{
                firestoreData.user.timerCount = 0
            }
            
        }
        
        .onChange(of: scenePhase) { phase in
            if !firestoreData.user.userInfo.name.isEqual(""){
                if phase == .background || phase == .inactive{
                    firestoreData.updateUser()
                    timer.upstream.connect().cancel()
                }
                if phase == .active{
                    self.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
                }
            }
            else{
                print("qqq")
            }
            
        }
    }
    
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewController()
    }
}
