//
//  FirestoreData.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/11.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import FacebookLogin

class FirestoreData: ObservableObject {
    @Published var user = User(id: "", uid: "", userInfo: UserInfo(method: "", name: "", image: "", email: "", password: "", registerTime: "", playTimes: 0, numberOfWins: 0), historys: [], heartsNum: 5, timerCount: 0, usedCodes: [])
    
    @Published var currentRoom = GameRoom(id: "", roomCode: "", playerIDs: [], roomState: "waiting", hostID: "", readyPlayerIDs: [])
    @Published var listener: ListenerRegistration?
    @Published var roomPlayers: [User] = []
    @Published var oldPlayerIDs: [String] = []
    @Published var tmpRoomPlayers: [User] = []
    @Published var roomIsFull = false
    @Published var roomExist = true
    @Published var roomPlaying = false
    @Published var isReady = false
    @Published var userNotReady = true
    @Published var getCoupon = false
    var hadCoupon = false
    var roomDocId = ""
    var userDocId = ""
    var count = 0
    
    func getUid() -> String {
        if let user = Auth.auth().currentUser {
            self.user.uid = user.uid
        }
        return user.uid
    }
    func initUser(){
        self.user = User(id: "", uid: "", userInfo: UserInfo(method: "", name: "", image: "", email: "", password: "", registerTime: "", playTimes: 0, numberOfWins: 0), historys: [], heartsNum: 5, timerCount: 0, usedCodes: [])
    }
    func creatUser(method: String, name: String, registerTime: String, uid: String){
        print("creat user")
        self.user.userInfo.image = "https://firebasestorage.googleapis.com/v0/b/ios-finalproject-60089.appspot.com/o/CE9B1B24-09A0-40AB-8A5D-8DA3792C4740.jpg?alt=media&token=9ef67283-751d-4717-af70-5c909f92cd24"
        self.user.uid = uid
        self.user.userInfo.method = method
        self.user.userInfo.name = name
        self.user.userInfo.registerTime = registerTime
        self.user.heartsNum = 5
        self.user.timerCount = 0
        let db = Firestore.firestore()
        do{
            let documentReference = try db.collection("users").addDocument(from: user)
            self.userDocId = documentReference.documentID
        }
        catch{
            print(error)
        }
        print(self.user.id)
        
    }
    
    func saveHistory(history: History, isWinner: Bool){
        print("save history")
        if(isWinner){
            self.user.userInfo.numberOfWins = self.user.userInfo.numberOfWins + 1
        }
        self.user.userInfo.playTimes += 1
        self.user.historys.append(history)
        self.updateUser()
    }
    
    func updateUser(){
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments{ snapshot, error in
            guard let users = snapshot?.documents else {return}
            var user = users[0]
            let ref = user.reference
            do{
                try ref.setData(from: self.user)
            }
            catch{
                print(error)
            }
        }
    }
    func initRoom(){
        self.currentRoom = GameRoom(id: "", roomCode: "", playerIDs: [], roomState: "waiting", hostID: "", readyPlayerIDs: [])
        self.roomPlayers = []
        self.tmpRoomPlayers = []
        self.roomIsFull = false
        self.roomExist = true
        self.roomPlaying = false
        self.isReady = false
        self.userNotReady = true
    }
    func backToRoom(){
        self.roomIsFull = false
        self.roomExist = true
        self.roomPlaying = false
        self.isReady = false
        self.userNotReady = true
        self.currentRoom.roomState = "waiting"
        self.currentRoom.readyPlayerIDs = []
        self.updateRoom()
    }
    
    func creatRoom(){
        self.generateRoomCode()
        self.currentRoom.hostID = self.user.id!
        self.currentRoom.playerIDs = []
        self.currentRoom.playerIDs.append(self.user.id!)
        let db = Firestore.firestore()
        do{
            let documentReference = try db.collection("gameRooms").addDocument(from: currentRoom)
            self.roomDocId = documentReference.documentID
        }
        catch{
            print(error)
        }
        self.roomPlayers = []
        self.roomPlayers.append(self.user)
        
    }
    func addUserToRoom(roomCode: String){
        print("add")
        currentRoom.playerIDs = []
        let db = Firestore.firestore()
        db.collection("gameRooms").whereField("roomCode", isEqualTo: roomCode).getDocuments{ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            let rooms = snapshot.documents.compactMap{ snapshot in
                try? snapshot.data(as: GameRoom.self)
            }
            if(rooms.count>0){
                self.roomExist = true
                self.currentRoom = rooms[0]
                if(self.currentRoom.roomState == "waiting"){
                    self.roomPlaying = false
                    if(self.currentRoom.playerIDs.count<4){
                        self.roomIsFull = false
                        self.roomDocId = self.currentRoom.id!
                        self.currentRoom.playerIDs.append(self.user.id!)
                        self.updateRoom()
                        self.oldPlayerIDs = self.currentRoom.playerIDs
                        //self.checkRoomChange()
                        //self.getRoomPlayers()
                    }
                    else{
                        self.roomIsFull = true
                    }
                }
                else{
                    self.roomPlaying = true
                }
            }
            else{
                self.roomExist = false
            }
        }
    }
    func updateRoom(){
        print("update")
        let db = Firestore.firestore()
        db.collection("gameRooms").whereField("roomCode", isEqualTo: self.currentRoom.roomCode).getDocuments{ snapshot, error in
            guard let rooms = snapshot?.documents else {return}
            var room = rooms[0]
            
            let ref = room.reference
            do{
                try ref.setData(from: self.currentRoom)
                
            }
            catch{
                print(error)
            }
        }
    }
    func exitRoom(id: String){
        print("exit")
        if(id == self.user.id){
            self.isReady = false
            self.listener?.remove()
        }//當前玩家離開 終止listener
        let db = Firestore.firestore()
        if(self.checkHostIsUser(id: id)){
            print("\(id) exit")
            print("host exit")
            self.listener?.remove()
            let documentReference = db.collection("gameRooms").document(self.roomDocId)
            documentReference.delete()
            self.currentRoom.playerIDs = []
            
        }//離開的人是host
        else{
            print("\(id) exit")
            print("host still in room")
            if let index = self.currentRoom.playerIDs.firstIndex(of: id) {
                self.currentRoom.playerIDs.remove(at: index)
            }
            if let index = self.currentRoom.readyPlayerIDs.firstIndex(of: id) {
                self.currentRoom.readyPlayerIDs.remove(at: index)
            }
            self.updateRoom()
        }//離開的人不是host
    }
    
    func startGame(){
        if(self.currentRoom.readyPlayerIDs.count == self.currentRoom.playerIDs.count - 1){
            self.userNotReady = false
            self.currentRoom.roomState = "playing"
            self.roomPlaying = true
            updateRoom()
        }
        else{
            self.userNotReady = true
        }
    }
    
    
    func getRoomPlayer(id: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(id).getDocument{ document, error in
            guard let document = document, document.exists, let user = try? document.data(as: User.self) else{
                completion(false)
                print("123false")
                return
            }
            //print("current get user")
            //print(user)
            self.tmpRoomPlayers.append(user)
            completion(true)
        }
    }
    
    func getPlayerFunc(completion: @escaping (Bool) -> Void) {
        getRoomPlayer(id: self.currentRoom.playerIDs[self.count]){ result in
            switch result {
            case true:
                print("get player")
                //print(self.tmpRoomPlayers[self.count])
                self.count += 1
                if self.count < self.currentRoom.playerIDs.count {
                    self.getPlayerFunc(){ _ in
                        if(self.tmpRoomPlayers.count == self.currentRoom.playerIDs.count){
                            self.roomPlayers = self.tmpRoomPlayers
                            NotificationCenter.default.post(name: Notification.Name("got room"), object: nil, userInfo: ["name": "peter", "age": 18])
                        }
                    }
                }
                else {
                    if(self.tmpRoomPlayers.count == self.currentRoom.playerIDs.count){
                        self.roomPlayers = self.tmpRoomPlayers
                        NotificationCenter.default.post(name: Notification.Name("got room"), object: nil, userInfo: ["name": "peter", "age": 18])
                    }
                    completion(true)
                }
                
            case false:
                print("false9876")
                completion(true)
            }
        }
    }
    
    func getRoomPlayers(){
        print("get players from firestore")
        
        self.tmpRoomPlayers = []
        self.count = 0
        getPlayerFunc(){ result in
            switch result {
            case true:
                print(self.tmpRoomPlayers.count)
            case false:
                print("failllll")
            }
        }
        
    }
    
    func whoExit(oldPlayerIDs: [String], newPlayerIDs: [String]){
        print("who exit")
        for oldID in oldPlayerIDs{
            if(!newPlayerIDs.contains(oldID)){
                exitRoom(id: oldID)
            }
        }
    }
    
    func checkUserReady(id: String) -> Bool{
        for readyId in self.currentRoom.readyPlayerIDs{
            if(readyId == id){
                return true
            }
        }
        return false
    }
    
    func getPlayerReadyState(){
        print("get ready state")
        if(self.currentRoom.readyPlayerIDs.count == self.currentRoom.playerIDs.count - 1 && self.currentRoom.readyPlayerIDs.count != 0){
            self.userNotReady = false
        }
        else{
            self.userNotReady = true
        }
    }
    func checkStart(){
        if self.currentRoom.roomState == "playing"{
            NotificationCenter.default.post(name: Notification.Name("game started"), object: nil, userInfo: ["name": "peter", "age": 18])
        }
    }
    
    func addHeartsNum(){
        self.user.heartsNum += 1
        self.updateUser()
    }
    
    func subHeartsNum(){
        self.user.heartsNum -= 1
        self.updateUser()
    }
    
    func checkRoomChange() -> ListenerRegistration? {
        let db = Firestore.firestore()
        return db.collection("gameRooms").document(self.roomDocId).addSnapshotListener{ snapshot, error in
            guard let snapshot = snapshot else{ return }
            guard let room = try? snapshot.data(as: GameRoom.self) else{
                NotificationCenter.default.post(name: Notification.Name("host exited"), object: nil, userInfo: ["name": "peter", "age": 18])
                return
            }
            print("check room change")
            self.oldPlayerIDs = self.currentRoom.playerIDs
            self.currentRoom = room
            if(self.oldPlayerIDs.count > self.currentRoom.playerIDs.count){
                self.whoExit(oldPlayerIDs: self.oldPlayerIDs, newPlayerIDs: self.currentRoom.playerIDs)
            }
            if(self.currentRoom.playerIDs.count != 0){
                self.getRoomPlayers()
            }
            self.getPlayerReadyState()
            self.checkStart()
            
        }
    }
    
    func userGetReady(){
        print("Get ready!")
        self.currentRoom.readyPlayerIDs.append(self.user.id!)
        self.isReady = true
        self.updateRoom()
    }
    
    func userCancleReady(){
        print("Cancle Ready!")
        self.isReady = false
        if let index = self.currentRoom.readyPlayerIDs.firstIndex(of: self.user.id!) {
            self.currentRoom.readyPlayerIDs.remove(at: index)
        }
        updateRoom()
    }
    
    
    func checkHostIsUser(id: String) -> Bool{
        if(self.currentRoom.hostID == id){
            return true
        }
        else{
            return false
        }
    }
    
    func generateRoomCode(){
        var tmpRoomCode = ""
        for _ in 0..<4{
            tmpRoomCode += "\(Int.random(in: 0..<10))"
        }
        self.currentRoom.roomCode = tmpRoomCode
    }
    func logOut(){
        do{
            try Auth.auth().signOut()
        }
        catch{
            print(error)
        }
        
    }
    func addTimerCount(){
        self.user.timerCount+=1
        //self.updateUser()
    }
    func fillHeart(){
        self.user.timerCount = 0
        self.addHeartsNum()
    }
    
    func useCoupon(code: String){
        let db = Firestore.firestore()
        db.collection("couponCodes").whereField("code", isEqualTo: code).getDocuments{ snapshot, error in
            guard let codes = snapshot?.documents else {return}
            
            if(codes.count == 0){
                self.getCoupon = false
                self.hadCoupon = false
            }//code 不存在
            else{
                if(self.user.usedCodes.contains(where: {$0 == code})){
                    print("有ㄌ")
                    self.getCoupon = false
                    self.hadCoupon = true
                }
                else{
                    self.getCoupon = true
                    self.hadCoupon = false
                    self.user.usedCodes.append(code)
                    if(self.user.heartsNum < 5){
                        self.user.heartsNum += 1
                    }
                    self.updateUser()
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name("use coupon"), object: nil, userInfo: ["name": "peter", "age": 18])
        }
        
    }
}
