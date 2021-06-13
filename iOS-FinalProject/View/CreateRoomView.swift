//
//  CreateRoomView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/13.
//

import SwiftUI

struct CreateRoomView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var soundController: SoundController
    @State private var roomCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    let getRoomNotification = NotificationCenter.default.publisher(for: Notification.Name("got room"))
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            VStack{
                HStack{
                    Button(action: {
                        soundController.playPoyoMusic()
                        firestoreData.creatRoom()
                        firestoreData.listener = firestoreData.checkRoomChange()
                    }, label: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 247/255, green: 202/255, blue: 205/255))
                            .frame(width: UIScreen.screenHeight / 3.5, height: UIScreen.screenHeight / 9, alignment: .center)
                            .overlay(
                                Text("Build a room")
                            )
                    })
                }
                HStack{
                    TextField("roomCode", text: $roomCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: UIScreen.screenWidth / 3.5)
                    Button(action: {
                        soundController.playPoyoMusic()
                        firestoreData.addUserToRoom(roomCode: roomCode)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            if(!firestoreData.roomIsFull && firestoreData.roomExist && !firestoreData.roomPlaying){
                                firestoreData.listener = firestoreData.checkRoomChange()
                            }
                            else{
                                if(firestoreData.roomIsFull){
                                    alertMessage = "The room is full"
                                }
                                else if(firestoreData.roomPlaying){
                                    alertMessage = "The room is playing"
                                }
                                else if(!firestoreData.roomExist){
                                    alertMessage = "The room doesn't exist"
                                }
                                showAlert = true
                            }
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 247/255, green: 202/255, blue: 205/255))
                            .frame(width: UIScreen.screenHeight / 3.5, height: UIScreen.screenHeight / 9, alignment: .center)
                            .overlay(
                                Text("Enter the room")
                            )
                    })
                }
            }
            
            Button(action: {
                soundController.playPoyoMusic()
                gameObject.currentState = .home
            }){
                Image("previous")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                
            }
            .offset(x: -UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            return Alert(title: Text(self.alertMessage))
        }
        .onReceive(getRoomNotification, perform: { _ in
            gameObject.currentState = .gameRoom
        })
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
            .previewLayout(.fixed(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
    }
}
