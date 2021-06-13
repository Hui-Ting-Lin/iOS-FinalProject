//
//  RoomView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/15.
//

import SwiftUI
import AVFoundation

struct RoomView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var firestoreGame: FirestoreGame
    @EnvironmentObject var soundController: SoundController
    @State private var alertMessage = ""
    @State private var showAlert = false
    let hostExitNotification = NotificationCenter.default.publisher(for: Notification.Name("host exited"))
    let gameStartedNotification = NotificationCenter.default.publisher(for: Notification.Name("game started"))
    let gotGameNotification = NotificationCenter.default.publisher(for: Notification.Name("got game"))
    let gameCreatedNotification = NotificationCenter.default.publisher(for: Notification.Name("game created"))
    var body: some View {
        
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            
            Text(firestoreData.currentRoom.roomCode)
                .offset(x: UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
            VStack{
                HStack{
                    ForEach(0..<4){ index in
                        if(index<firestoreData.roomPlayers.count){
                            let currentId = firestoreData.roomPlayers[index].id!
                            playerView(player: firestoreData.roomPlayers[index], isReady: firestoreData.checkUserReady(id: currentId), isHost: firestoreData.checkHostIsUser(id: currentId))
                        }
                        else{
                            emptyPlayer()
                        }
                    }
                }
                if(firestoreData.checkHostIsUser(id: firestoreData.user.id!)){
                    Button(action: {
                        soundController.playPoyoMusic()
                        if(firestoreData.userNotReady){
                            alertMessage = "Users not ready yet!"
                            showAlert = true
                        }
                        else{
                            firestoreGame.initGame(users: firestoreData.roomPlayers, roomCode: firestoreData.currentRoom.roomCode, isHost: firestoreData.checkHostIsUser(id: firestoreData.user.id!))
                            firestoreGame.creatGame(userId: firestoreData.user.id!)
                            firestoreData.startGame()
                        }
                    }){
                        Text("start game")
                    }
                }
                else{
                    if(!firestoreData.isReady){
                        Button(action: {
                            soundController.playPoyoMusic()
                            firestoreData.userGetReady()
                        }){
                            Text("ready")
                        }
                    }
                    else{
                        Button(action: {
                            soundController.playPoyoMusic()
                            firestoreData.userCancleReady()
                        }){
                            Text("cancle ready")
                        }
                    }
                }
            }
            Button(action: {
                soundController.playPoyoMusic()
                firestoreData.exitRoom(id: firestoreData.user.id!)
                soundController.playLobbyMusic()
                gameObject.currentState = .intoRoom
            }){
                Image("previous")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                
            }
            .offset(x: -UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
        }
        .onReceive(hostExitNotification, perform: { _ in
            gameObject.currentState = .intoRoom
        })
        .onReceive(gameStartedNotification, perform: { _ in
            firestoreGame.roomCode = firestoreData.currentRoom.roomCode
            if(!firestoreData.checkHostIsUser(id: firestoreData.user.id!)){
                firestoreGame.getGame(userId: firestoreData.user.id!)
            }
        })
        .onReceive(gotGameNotification, perform: { _ in
            gameObject.currentState = .game
        })
        .onReceive(gameCreatedNotification, perform: { _ in
            gameObject.currentState = .game
        })
        .alert(isPresented: $showAlert) { () -> Alert in
            return Alert(title: Text(self.alertMessage))
        }
        .onAppear{
            soundController.playWaitingMusic()
        }
    }
    
}
struct emptyPlayer: View{
    var body: some View{
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 255/255, green: 255/255, blue: 232/255))
            .frame(width: UIScreen.screenWidth*0.2, height: UIScreen.screenHeight*0.7, alignment: .center)
    }
}
struct playerView: View{
    var player: User
    var isReady: Bool
    var isHost: Bool
    var body: some View{
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 255/255, green: 255/255, blue: 232/255))
            .frame(width: UIScreen.screenWidth*0.2, height: UIScreen.screenHeight*0.7, alignment: .center)
            .overlay(
                VStack{
                    Image(systemName: "defaultImg").data(url: URL(string: player.userInfo.image)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenHeight * 0.3, height:  UIScreen.screenHeight * 0.3)
                        .clipped()
                    Text(player.userInfo.name)
                    if(isHost){
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 247/255, green: 202/255, blue: 205/255))
                            .frame(width: UIScreen.screenWidth*0.15, height: UIScreen.screenHeight/11, alignment: .center)
                            .overlay(
                                //Text("室   長")
                                Text("Host")
                            )
                            
                        
                    }
                    else{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isReady ? Color(red: 211/255, green: 246/255, blue: 219/255) : Color(red: 247/255, green: 202/255, blue: 205/255))
                            .frame(width: UIScreen.screenWidth*0.15, height: UIScreen.screenHeight/11, alignment: .center)
                            .overlay(
                                //Text(isReady ? "準   備" : "未 準 備")
                                
                                Text(isReady ? NSLocalizedString("Ready", comment: "") : NSLocalizedString("Not Ready", comment: ""))
                            )
                    }
                    
                }
            )
        
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView()
            .previewLayout(.fixed(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
    }
}
