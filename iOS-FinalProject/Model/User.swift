//
//  User.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/22.
//

import SwiftUI
import FirebaseFirestoreSwift

struct User: Codable, Identifiable{
    @DocumentID var id: String?
    var uid: String
    var userInfo: UserInfo
    var historys: [History]
    var heartsNum: Int
    var timerCount: Int
    var usedCodes: [String]
    
}


struct UserInfo: Codable {
    var method: String
    var name: String
    var image: String
    var email: String
    var password: String
    var registerTime: String
    var playTimes: Int
    var numberOfWins: Int
}

struct History: Codable {
    var winner: String
    var timeStamp: String
    var spendTime: String
    var win: Bool
}

struct GameRoom: Codable, Identifiable{
    @DocumentID var id: String?
    var roomCode: String
    var playerIDs: [String]
    var roomState: String
    var hostID: String
    var readyPlayerIDs: [String]
}
