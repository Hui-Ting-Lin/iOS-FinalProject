//
//  ResultView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/6/3.
//


import SwiftUI
import AVFoundation

struct ResultView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    @EnvironmentObject var firestoreGame: FirestoreGame
    @EnvironmentObject var soundController: SoundController
    var body: some View {
        ZStack(){
            Color(red: 255/255, green: 255/255, blue: 232/255)
                .ignoresSafeArea()
            VStack{
                Text(firestoreGame.isWinner ? !firestoreGame.game.winner.isEqual("both") ?  NSLocalizedString("Win!!!", comment: "") : NSLocalizedString("Fever!!", comment: "") : NSLocalizedString("Lose...", comment: ""))
                 .bold()
                 .font(.system(size: 40))
                 .foregroundColor(Color.blue)
                Text("Red Team Score: \(firestoreGame.game.redScore)")
                    .frame(width: UIScreen.screenWidth*0.7, height: UIScreen.screenHeight*0.07, alignment: .leading)
                    .background(Color.red)
                ForEach(0..<firestoreGame.game.gamePlayers.count){ i in
                    if(firestoreGame.game.gamePlayers[i].team.isEqual("red")){
                        ResultRow(player: firestoreGame.game.gamePlayers[i], team: "red")
                    }
                }
                Text("Green Team Score: \(firestoreGame.game.greenScore)")
                    .frame(width: UIScreen.screenWidth*0.7, height: UIScreen.screenHeight*0.07, alignment: .leading)
                    .background(Color.green)
                ForEach(0..<firestoreGame.game.gamePlayers.count){ i in
                    if(firestoreGame.game.gamePlayers[i].team.isEqual("green")){
                        ResultRow(player: firestoreGame.game.gamePlayers[i], team: "green")
                    }
                }
                Button(action: {
                    firestoreData.backToRoom()
                    firestoreGame.deleteGame()
                    gameObject.currentState = .gameRoom
                }, label: {
                    Text("Back to room")
                })
            }
            
        }
        .onAppear{
            if(firestoreGame.isWinner){
                soundController.playWinMusic()
            }
            else{
                soundController.playLoseMusic()
            }
        }
    }
    
}

struct ResultRow: View {
    var player: Player
    var team: String
    var body: some View{
        HStack{
            Image(player.image)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenHeight * 0.08, height: UIScreen.screenHeight * 0.08, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Text(player.name)
        }
        .frame(width: UIScreen.screenWidth*0.7, height: UIScreen.screenHeight*0.09, alignment: .leading)
        .background(team.isEqual("red") ? Color.red.opacity(0.8) : Color.green.opacity(0.6))
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
            .previewLayout(.fixed(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
    }
}
