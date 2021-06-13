//
//  GameView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/23.
//

import SwiftUI
import AVFoundation

struct GameView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var firestoreGame: FirestoreGame
    @EnvironmentObject var soundController: SoundController
    let gameOverNotification = NotificationCenter.default.publisher(for: Notification.Name("game over"))
    @State private var showResult = false
    @State private var time = 180
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var dieCounter = 0
    @State private var currentDate = Date()
    @State private var showClock = false
    
    var body: some View {
        ZStack(){
            Color(red: 255/255, green: 255/255, blue: 232/255)
                .ignoresSafeArea()
            MapView
                .offset(y: UIScreen.screenHeight * 0.03)
            
            CharacterView
                .offset(x: -UIScreen.screenWidth*0.4)
            
            ArrowKeys
                .offset(x: -UIScreen.screenWidth*0.4, y: UIScreen.screenHeight*0.38)
            PointsTable
                .offset(x: UIScreen.screenWidth*0.4, y: -UIScreen.screenHeight*0.35)
            TimeView(time: time)
                .offset(x: -UIScreen.screenWidth*0.4, y: -UIScreen.screenHeight*0.35)
            if(showClock){
                ClockView
            }
            
        }
        .onAppear{
            if(!firestoreData.checkHostIsUser(id: firestoreData.user.id!)){
                time = 178
            }
            else{
                time = 180
            }
            firestoreData.subHeartsNum()
        }
        .onReceive(gameOverNotification, perform: { _ in
            firestoreData.saveHistory(history: History(winner: "\(firestoreGame.game.winner)", timeStamp: getTime(), spendTime: "\(180-time) sec", win: firestoreGame.isWinner), isWinner: firestoreGame.isWinner)
            gameObject.currentState = .result
        })
        .onReceive(timer){ input in
            time -= 1
            if(time % 2 == 0){
                firestoreGame.moveGoast(isHost: firestoreData.checkHostIsUser(id: firestoreData.user.id!))
            }
            
            if(firestoreGame.game.gamePlayers[firestoreGame.currentPlayerIndex].die){
                if(dieCounter < 3){
                    if(dieCounter==0){
                        soundController.playDieMusic()
                    }
                    showClock = true
                    dieCounter += 1
                    soundController.playDingMusic()
                }
                else{
                    showClock = false
                    dieCounter = 0
                    firestoreGame.playerRevive()
                }
            }
            if(time==0){
                timer.upstream.connect().cancel()
                firestoreGame.timesUp()
            }
            
        }
        
        .onAppear{
            soundController.playGameStartMusic()
            soundController.playGameMusic()
        }
    }
    var ClockView: some View{
        Image("clock")
            .resizable()
            .frame(width: UIScreen.screenHeight*0.5, height: UIScreen.screenHeight*0.5)
            .overlay(
                Image("\(3-dieCounter+1)img")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.2, height: UIScreen.screenHeight*0.2)
            )
    }
    var PointsTable: some View{
        VStack{
            HStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
                    .frame(width: UIScreen.screenHeight*0.15, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .overlay(
                        Text("Red")
                            .foregroundColor(.white)
                    )
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .frame(width: UIScreen.screenHeight*0.15, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .overlay(
                        Text("\(firestoreGame.game.redScore)")
                            .foregroundColor(.white)
                    )
            }
            HStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: UIScreen.screenHeight*0.15, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .overlay(
                        Text("Green")
                            .foregroundColor(.white)
                    )
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .frame(width: UIScreen.screenHeight*0.15, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .overlay(
                        Text("\(firestoreGame.game.greenScore)")
                            .foregroundColor(.white)
                    )
            }
            
        }
    }
    var CharacterView: some View{
        Image(firestoreGame.game.gamePlayers[firestoreGame.currentPlayerIndex].image)
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.screenHeight * 0.5, height: UIScreen.screenHeight * 0.5)
    }
    var MapView: some View{
        VStack(spacing: 0){
            ForEach(0..<11){ row in
                HStack(spacing: 0){
                    ForEach(0..<15){ col in
                        MapItemView(row: row, col: col)
                            .environmentObject(firestoreGame)
                        
                    }
                }
                
            }
        }
    }
    var ArrowKeys: some View{
        VStack{
            Button(action: {
                firestoreGame.playerGo(id: firestoreGame.game.gamePlayers[firestoreGame.currentPlayerIndex].id, direction: "up")
            },label:{
                Arrow(keyName: "up-arrow")
            })
            HStack{
                Button(action: {
                    firestoreGame.playerGo(id: firestoreGame.game.gamePlayers[firestoreGame.currentPlayerIndex].id, direction: "left")
                },label:{
                    Arrow(keyName: "left-arrow")
                })
                Button(action: {
                    firestoreGame.playerGo(id: firestoreGame.game.gamePlayers[firestoreGame.currentPlayerIndex].id, direction: "down")
                },label:{
                    Arrow(keyName: "down-arrow")
                })
                Button(action: {
                    firestoreGame.playerGo(id: firestoreGame.game.gamePlayers[firestoreGame.currentPlayerIndex].id, direction: "right")
                },label:{
                    Arrow(keyName: "right-arrow")
                })
            }
        }
    }
}

func getTime() -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: Date())
}
struct TimeView: View{
    var time: Int
    var body: some View{
        HStack(spacing: 5){
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
                .frame(width: UIScreen.screenHeight*0.06, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(
                    Text("0")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
                .frame(width: UIScreen.screenHeight*0.06, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(
                    Text("\(time/60)")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
                .frame(width: UIScreen.screenHeight*0.06, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(
                    Text(":")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
                .frame(width: UIScreen.screenHeight*0.06, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(
                    Text("\((time%60)/10)")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
                .frame(width: UIScreen.screenHeight*0.06, height: UIScreen.screenHeight*0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(
                    Text("\((time%60)%10)")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
        }
    }
    
}
struct MapItemView: View{
    @EnvironmentObject var firestoreGame: FirestoreGame
    var row: Int
    var col: Int
    var body: some View{
        ZStack{
            Image("\(firestoreGame.game.gameMap.mapItems[row*15+col].background)")
                .resizable()
                .frame(width: UIScreen.screenHeight / 11.5 , height: UIScreen.screenHeight / 11.5)
            
            if(!firestoreGame.game.gameMap.mapItems[row*15+col].isTreasure && firestoreGame.game.gameMap.mapItems[row*15+col].dot.show){
                Circle()
                    .fill(firestoreGame.game.gameMap.mapItems[row*15+col].dot.color == "gray" ? Color.gray : firestoreGame.game.gameMap.mapItems[row*15+col].dot.color == "red" ? Color.red : Color.green)
                    .frame(width: UIScreen.screenHeight / 60, height: UIScreen.screenHeight / 60)
            }
            ForEach(0..<firestoreGame.game.goasts.count){ index in
                var goast = firestoreGame.game.goasts[index]
                if(row == goast.location.row && col == goast.location.col){
                    if(goast.direction.isEqual("left")){
                        Image("goast-l")
                            .resizable()
                            .frame(width: UIScreen.screenHeight / 11.5 , height: UIScreen.screenHeight / 11.5)
                    }
                    else{
                        Image("goast-r")
                            .resizable()
                            .frame(width: UIScreen.screenHeight / 11.5 , height: UIScreen.screenHeight / 11.5)
                    }
                }
            }
            ForEach(firestoreGame.game.gamePlayers){ player in
                if(row == player.location.row && col == player.location.col){
                    if(!player.die){
                        Image("\(player.image)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.screenHeight / 11.5 , height: UIScreen.screenHeight / 11.5)
                    }
                }
            }
        }
    }
}

struct Arrow: View{
    var keyName: String
    var body: some View{
        Image(keyName)
            .resizable()
            .frame(width: UIScreen.screenHeight / 10, height: UIScreen.screenHeight / 10)
    }
}



struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .previewLayout(.fixed(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
    }
}
