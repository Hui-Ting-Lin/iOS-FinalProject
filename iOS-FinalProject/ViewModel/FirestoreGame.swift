//
//  FirestoreGame.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/27.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

class FirestoreGame: FireStoreGameModel , ObservableObject{
    
    var playerLocations = [Location(row: 0, col: 0), Location(row: 10, col: 14), Location(row: 0, col: 14), Location(row: 10, col: 0)]
    var characters = ["cha1", "cha2", "cha3", "cha4"]
    
    @Published var roomCode = ""
    @Published var listener: ListenerRegistration?
    @Published var game = Game()
    @Published var gameId = ""
    @Published var isWinner = false
    @Published var currentPlayerIndex = 0
    var showedResult = false
    
    func creatGame(userId: String){
        let db = Firestore.firestore()
        do{
            let documentReference = try db.collection("games").addDocument(from: game)
            self.gameId = documentReference.documentID
            self.getCurrentPlayerIndex(userId: userId)
            self.listener = self.checkGameChange()
            
            NotificationCenter.default.post(name: Notification.Name("game created"), object: nil, userInfo: ["name": "peter", "age": 18])
        }
        catch{
            print(error)
        }
    }
    
    func getGame(userId: String){
        print("get game")
        let db = Firestore.firestore()
        db.collection("games").whereField("roomCode", isEqualTo: self.roomCode).getDocuments{ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            let games = snapshot.documents.compactMap{ snapshot in
                try? snapshot.data(as: Game.self)
            }
            self.game = games[0]
            self.gameId = self.game.id!
            self.getCurrentPlayerIndex(userId: userId)
            self.listener = self.checkGameChange()
            NotificationCenter.default.post(name: Notification.Name("got game"), object: nil, userInfo: ["name": "peter", "age": 18])
        }
        
    }
    
    
    
    func playerGo(id: String, direction: String){
        var update = false
        if(!self.game.gamePlayers[self.currentPlayerIndex].die){
            switch direction {
            case "up":
                if(self.game.gamePlayers[self.currentPlayerIndex].location.row >= 1){
                    if(!self.game.gameMap.mapItems[(self.game.gamePlayers[self.currentPlayerIndex].location.row-1) * 15 +  self.game.gamePlayers[self.currentPlayerIndex].location.col].isTreasure){
                        self.game.gamePlayers[self.currentPlayerIndex].location.row -= 1
                        updateGamePlayers(id: self.game.id!, gamePlayersDictionary: gamePlayersToDictionary())
                        update = true
                    }
                    else{
                        print("is treasure")
                    }
                }
                else{
                    print("can't go up")
                }
                
            case "down":
                if(self.game.gamePlayers[self.currentPlayerIndex].location.row <= 9){
                    if(!self.game.gameMap.mapItems[(self.game.gamePlayers[self.currentPlayerIndex].location.row+1) * 15 +  self.game.gamePlayers[self.currentPlayerIndex].location.col].isTreasure){
                        self.game.gamePlayers[self.currentPlayerIndex].location.row += 1
                        updateGamePlayers(id: self.game.id!, gamePlayersDictionary: gamePlayersToDictionary())
                        update = true
                    }
                    else{
                        print("is treasure")
                    }
                }
                else{
                    print("can't go down")
                }
            case "left":
                if(self.game.gamePlayers[self.currentPlayerIndex].location.col >= 1){
                    if(!self.game.gameMap.mapItems[self.game.gamePlayers[self.currentPlayerIndex].location.row * 15 +  (self.game.gamePlayers[self.currentPlayerIndex].location.col-1)].isTreasure){
                        self.game.gamePlayers[self.currentPlayerIndex].location.col -= 1
                        updateGamePlayers(id: self.game.id!, gamePlayersDictionary: gamePlayersToDictionary())
                        update = true
                    }
                    else{
                        print("is treasure")
                    }
                }
                else{
                    print("can't go left")
                }
            case "right":
                if(self.game.gamePlayers[self.currentPlayerIndex].location.col <= 13){
                    if(!self.game.gameMap.mapItems[self.game.gamePlayers[self.currentPlayerIndex].location.row * 15 +  (self.game.gamePlayers[self.currentPlayerIndex].location.col+1)].isTreasure){
                        self.game.gamePlayers[self.currentPlayerIndex].location.col += 1
                        updateGamePlayers(id: self.game.id!, gamePlayersDictionary: gamePlayersToDictionary())
                        update = true
                    }
                    else{
                        print("is treasure")
                    }
                }
                else{
                    print("can't go right")
                }
            default:
                print(self.game.gamePlayers[self.currentPlayerIndex].location)
                update = false
            }
        }
        
        
        if(update){
            self.game.gameMap.mapItems[self.game.gamePlayers[self.currentPlayerIndex].location.row * 15 + self.game.gamePlayers[self.currentPlayerIndex].location.col].dot.color = self.game.gamePlayers[self.currentPlayerIndex].team
            self.updateTreasuresDots(playerLoc: self.game.gamePlayers[self.currentPlayerIndex].location, color: self.game.gamePlayers[self.currentPlayerIndex].team)
        }
    }
    
    func updateTreasuresDots(playerLoc: Location, color: String){
        var treasureUpdate = false
        for j in 0..<self.game.gameMap.treasures.count{
            treasureUpdate = false
            if(!self.game.gameMap.treasures[j].isOpen){
                for i in 0..<self.game.gameMap.treasures[j].dots.count{
                    let dotLoc = Location(row: self.game.gameMap.treasures[j].dots[i].row, col: self.game.gameMap.treasures[j].dots[i].col)
                    if(dotLoc.sameLoc(location: playerLoc)){
                        treasureUpdate = true
                        self.game.gameMap.treasures[j].dots[i].color = color
                    }
                }
            }
            
            if(treasureUpdate){
                judgeTreasure(treasure: self.game.gameMap.treasures[j], index: j)
            }
            
        }
        updateGameMap(id: self.game.id!, gameMapDictionary: self.game.gameMap.dictionary)
        
    }
    
    func judgeGoast(loc: Location){
        print("judge goast")
        var update = false
        for i in 0..<self.game.goasts.count{
            if(self.game.goasts[i].location.sameLoc(location: loc)){
                print("meet goast")
                update = true
                self.game.gamePlayers[self.currentPlayerIndex].die = true
            }
        }
        if(update){
            updateGamePlayers(id: self.game.id!, gamePlayersDictionary: self.gamePlayersToDictionary())
        }
        
    }
    
    func playerRevive(){
        print("revive!")
        self.game.gamePlayers[self.currentPlayerIndex].die = false
        updateGamePlayers(id: self.game.id!, gamePlayersDictionary: gamePlayersToDictionary())
    }
    
    func judgeTreasure(treasure: Treasure, index: Int){
        var redDot = 0
        var greenDot = 0
        for dot in treasure.dots{
            if(dot.color == "red"){
                redDot += 1
            }
            else if(dot.color == "green"){
                greenDot += 1
            }
        }
        if(redDot == treasure.dots.count){
            self.getTreasure(team: "red", value: treasure.value, loc: treasure.location, treasure: treasure, index: index)
        }
        else if(greenDot == treasure.dots.count){
            self.getTreasure(team: "green", value: treasure.value, loc: treasure.location, treasure: treasure, index: index)
        }
    }
    
    func getTreasure(team: String, value: Int, loc: Location, treasure: Treasure, index: Int){
        let redTreasureImg = [6, 7]
        let greenTreasureImg = [4, 5]
        if(team == "red"){
            if(!self.game.gameMap.treasures[index].isOpen){
                for col in treasure.location.col..<treasure.location.col + treasure.num{
                    
                    self.game.redScore += treasure.value
                    self.game.gameMap.mapItems[treasure.location.row*15+col].background = redTreasureImg.randomElement()!
                    
                    self.game.gameMap.treasures[index].isOpen = true
                    self.checkGameOver()
                }
            }
            
        }
        else{
            if(!self.game.gameMap.treasures[index].isOpen){
                for col in treasure.location.col..<treasure.location.col + treasure.num{
                    self.game.greenScore += treasure.value
                    self.game.gameMap.mapItems[treasure.location.row*15+col].background = greenTreasureImg.randomElement()!
                    
                    self.game.gameMap.treasures[index].isOpen = true
                    self.checkGameOver()
                }
            }
        }
        /*
         for dot in treasure.dots{
         self.game.gameMap.mapItems[dot.row * 15 + dot.col].dot.show = false
         }*/
        print("red score: \(self.game.redScore)")
        print("green score: \(self.game.greenScore)")
        
        updateGameMap(id: self.game.id!, gameMapDictionary: self.game.gameMap.dictionary)
        updateScore(id: self.game.id!, redScore: self.game.redScore, greenScore: self.game.greenScore)
    }
    
    func deleteGame(){
        self.listener?.remove()
        let documentReference = db.collection("games").document(self.game.id!)
        documentReference.delete()
    }
    
    func initGame(users: [User], roomCode: String, isHost: Bool){
        var tmpUsers = users
        self.game = Game()
        self.showedResult = false
        self.game.roomCode = roomCode
        self.roomCode = roomCode
        self.characters.shuffle()
        
        if(users.count != 0){
            for i in 0..<tmpUsers.count / 2{
                let tmpPlayer = Player(id: tmpUsers[i].id!, team: "red", location: self.playerLocations[i], image: characters[i], name: tmpUsers[i].userInfo.name, die: false)
                self.game.gamePlayers.append(tmpPlayer)
                self.game.gameMap.mapItems[tmpPlayer.location.row*15 +  tmpPlayer.location.col].dot.color = tmpPlayer.team
            }
            for i in tmpUsers.count / 2..<tmpUsers.count{
                let tmpPlayer = Player(id: tmpUsers[i].id!, team: "green", location: self.playerLocations[i], image: characters[i], name: tmpUsers[i].userInfo.name, die: false)
                self.game.gamePlayers.append(tmpPlayer)
                self.game.gameMap.mapItems[tmpPlayer.location.row*15 +  tmpPlayer.location.col].dot.color = tmpPlayer.team
            }
            
        }
        
        self.getDotArround()
        
    }
    
    func moveGoast(isHost: Bool){
        for i in 0..<self.game.goasts.count{
            if(self.game.goasts[i].direction.isEqual("left")){
                if(self.game.goasts[i].location.col >= 1){
                    self.game.goasts[i].location.col -= 1
                }
                else{
                    self.game.goasts[i].direction = "right"
                    self.game.goasts[i].location.col += 1
                }
            }
            else{
                if(self.game.goasts[i].location.col <= 13){
                    self.game.goasts[i].location.col += 1
                }
                else{
                    self.game.goasts[i].direction = "left"
                    self.game.goasts[i].location.col -= 1
                }
            }
        }
        if(isHost){
            self.updateGoasts(id: self.game.id!, goastDictionary: goastsToDictionary())
        }
        self.judgeGoast(loc: self.game.gamePlayers[self.currentPlayerIndex].location)
    }
    
    func checkGameOver(){
        var count = 0
        for treasure in self.game.gameMap.treasures{
            if(treasure.isOpen){
                count+=1
            }
            else{
                break
            }
        }
        if(count==self.game.gameMap.treasures.count && !self.game.state.isEqual("over")){
            self.game.state = "over"
            if(self.game.redScore>self.game.greenScore){
                self.game.winner = "red"
            }
            else if(self.game.redScore<self.game.greenScore){
                self.game.winner = "green"
            }
            else{
                self.game.winner = "both"
            }
            if(self.game.gamePlayers[self.currentPlayerIndex].team == self.game.winner){
                self.isWinner = true
            }
            else{
                self.isWinner = false
            }
            updateWinner(id: self.game.id!, winner: self.game.winner)
            updateState(id: self.game.id!, state: self.game.state)
            
        }
        
    }
    
    func getCurrentPlayerIndex(userId: String){
        print("get current player")
        for i in 0..<self.game.gamePlayers.count{
            if(self.game.gamePlayers[i].id == userId){
                self.currentPlayerIndex = i
            }
        }
    }
    
    func showResult(winner: String){
        if(winner==self.game.gamePlayers[self.currentPlayerIndex].team){
            self.isWinner = true
        }
        
        self.showedResult = true
        NotificationCenter.default.post(name: Notification.Name("game over"), object: nil, userInfo: ["name": "peter", "age": 18])
    }
    
    func checkGameChange() -> ListenerRegistration? {
        let db = Firestore.firestore()
        return db.collection("games").document(self.gameId).addSnapshotListener{ snapshot, error in
            guard let snapshot = snapshot else{ return}
            guard let game = try? snapshot.data(as: Game.self) else{return}
            print("check game change")
            self.game = game
            if(self.game.state.isEqual("over") && !self.showedResult){
                print("check over !")
                self.showResult(winner: self.game.winner)
            }
        }
    }
    
    
    func timesUp(){
        if(!self.game.state.isEqual("over")){
            self.game.state = "over"
            if(self.game.redScore>self.game.greenScore){
                self.game.winner = "red"
            }
            else if(self.game.redScore<self.game.greenScore){
                self.game.winner = "green"
            }
            else{
                self.game.winner = "both"
            }
            if(self.game.gamePlayers[self.currentPlayerIndex].team == self.game.winner){
                self.isWinner = true
            }
            else{
                self.isWinner = false
            }
            
            updateWinner(id: self.game.id!, winner: self.game.winner)
            updateState(id: self.game.id!, state: self.game.state)
        }
    }
    
    func gamePlayersToDictionary() -> [Dictionary<String,Any>] {
        var resultDictionary: [Dictionary<String,Any>] = []
        for player in self.game.gamePlayers {
            if(player.id==self.game.gamePlayers[self.currentPlayerIndex].id){
                resultDictionary.append(self.game.gamePlayers[self.currentPlayerIndex].dictionary)
            }
            else{
                resultDictionary.append(player.dictionary)
            }
        }
        return resultDictionary
    }
    
    func goastsToDictionary() -> [Dictionary<String,Any>] {
        var resultDictionary: [Dictionary<String,Any>] = []
        for goast in self.game.goasts {
            resultDictionary.append(goast.dictionary)
            
        }
        return resultDictionary
    }
    
    
    func getDotArround(){
        for i in 0..<self.game.gameMap.treasures.count{
            let treasure = self.game.gameMap.treasures[i]
            var dots: [Dot] = []
            for row in treasure.location.row-1..<treasure.location.row+2{
                for col in treasure.location.col-1..<treasure.location.col + treasure.num + 1{
                    if(!self.game.gameMap.mapItems[row*15+col].isTreasure){
                        dots.append(self.game.gameMap.mapItems[row*15+col].dot)
                    }
                }
            }
            self.game.gameMap.treasures[i].dots = dots
        }
        
    }
    
}

class FireStoreGameModel {
    let db = Firestore.firestore()
    
    
    func updateGamePlayers(id: String, gamePlayersDictionary: [Dictionary<String,Any>]) {
        db.collection("games").document(id).updateData([
            "gamePlayers": gamePlayersDictionary
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("game players successfully updated")
            }
        }
    }
    
    func updateGameMap(id: String, gameMapDictionary: Dictionary<String,Any>) {
        db.collection("games").document(id).updateData([
            "gameMap": gameMapDictionary
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("game map successfully updated")
            }
        }
    }
    
    func updateScore(id: String, redScore: Int, greenScore: Int) {
        db.collection("games").document(id).updateData([
            "redScore": redScore
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("game redScore successfully updated")
            }
        }
        db.collection("games").document(id).updateData([
            "greenScore": greenScore
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("game greenScore successfully updated")
            }
        }
    }
    
    func updateState(id: String, state: String) {
        db.collection("games").document(id).updateData([
            "state": state
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("game state successfully updated")
            }
        }
    }
    func updateWinner(id: String, winner: String) {
        db.collection("games").document(id).updateData([
            "winner": winner
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("game winner successfully updated")
            }
        }
    }
    
    
    func updateGoasts(id: String, goastDictionary: [Dictionary<String,Any>]) {
        db.collection("games").document(id).updateData([
            "goasts": goastDictionary
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Goast successfully updated")
            }
        }
    }
    
}
