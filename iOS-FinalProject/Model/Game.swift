//
//  Map.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/25.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI

struct MapItem: Codable{
    var background: Int
    var dot: Dot
    var isTreasure: Bool
    var row: Int
    var col: Int
    var dictionary: [String: Any] {
        return ["background": self.background,
                "dot": self.dot.dictionary,
                "isTreasure": self.isTreasure,
                "row": self.row,
                "col": self.col]
    }
}

struct Dot: Codable{
    var show: Bool = true
    var color: String = "gray"
    var row: Int
    var col: Int
    var dictionary: [String: Any] {
        return ["show": self.show,
                "color": self.color,
                "row": self.row,
                "col": self.col]
    }
}

struct Treasure: Codable{
    var location: Location
    var team: String = "none"
    var value: Int = 1
    var num: Int
    var isOpen: Bool = false
    var dots: [Dot] = []
    var dictionary: [String: Any] {
        return ["location": self.location.dictionary,
                "team": self.team,
                "value": self.value,
                "num": self.num,
                "isOpen": self.isOpen,
                "dots": dotsToDic()]
    }
    
    func dotsToDic() -> [Dictionary<String,Any>] {
        var dic: [Dictionary<String,Any>] = []
        for dot in self.dots {
            dic.append(dot.dictionary)
        }
        return dic
    }
}
struct Map: Codable {
    
    var mapItems: [MapItem]
    var treasures: [Treasure]
    var dictionary: [String: Any] {
        return ["mapItems": mapItemsToDic(),
                "treasures": treasuresToDic()]
    }
    
    func mapItemsToDic() -> [Dictionary<String,Any>] {
        var dic: [Dictionary<String,Any>] = []
        for item in self.mapItems {
            dic.append(item.dictionary)
        }
        return dic
    }
    func treasuresToDic() -> [Dictionary<String,Any>] {
        var dic: [Dictionary<String,Any>] = []
        for treasure in self.treasures {
            dic.append(treasure.dictionary)
        }
        return dic
    }
    
    init(){
        mapItems = []
        treasures = []
        self.treasures = mapTreasures
        for row in 0..<11{
            for col in 0..<15{
                
                let tmpItem = MapItem(background: mapBackGround[row][col], dot: Dot(row: row, col: col), isTreasure: false, row: row, col: col)
                self.mapItems.append(tmpItem)
                if(treasureImgNum.contains(mapItems[row * 15 + col].background)){
                    mapItems[row * 15 + col].isTreasure = true
                }
            }
        }
    }
}
struct Player: Codable, Identifiable{
    var id: String
    var team: String
    var location: Location
    var image: String
    var name: String
    var die: Bool
    
    var dictionary: [String: Any] {
        return ["id": self.id,
                "team": self.team,
                "location": self.location.dictionary,
                "image": self.image,
                "name": self.name,
                "die": self.die]
    }
}



struct Location: Codable{
    
    var row: Int
    var col: Int
    
    var dictionary: [String: Any] {
        return ["row": self.row,
                "col": self.col]
    }
}


struct Game: Codable, Identifiable{
    @DocumentID var id: String?
    var gameMap: Map
    var gamePlayers: [Player]
    var roomCode: String
    var redScore: Int = 0
    var greenScore: Int = 0
    var time: Int
    var winner: String
    var state: String
    var goasts: [Goast]
    
    init(){
        gameMap = Map()
        gamePlayers = []
        roomCode = "0000"
        redScore = 0
        greenScore = 0
        time = 0
        winner = "none"
        state = "playing"
        goasts = [Goast(location: Location(row: 2, col: 0), num: 0, direction: "right"),
                  Goast(location: Location(row: 4, col: 5), num: 0, direction: "right"),
                  Goast(location: Location(row: 6, col: 14), num: 1, direction: "left")]
    }
}

struct Goast: Codable{
    var location: Location
    var num: Int
    var direction: String
    var dictionary: [String: Any] {
        return ["location": self.location.dictionary,
                "num": self.num,
                "direction": self.direction]
    }
}

var mapBackGround = [[14, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 13],
                     [10, 1, 10, 1, 10, 1, 1, 1, 10, 1, 1, 1, 10 ,1, 10],
                     [10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 10],
                     [10, 1, 1, 10, 1, 10, 1, 1, 1, 1, 1, 10, 1 ,1, 10],
                     [10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 10],
                     [10, 1, 1, 1, 10, 1, 1, 10, 1, 1, 10, 1, 1 ,1, 10],
                     [10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 10],
                     [10, 1, 10, 1, 1, 10, 1, 1, 10, 1, 1, 1, 10 ,1, 10],
                     [10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 10],
                     [10, 1, 1, 10, 1, 1, 1, 1, 1, 1, 10, 1, 1 ,1, 10],
                     [10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 10]]
/*
                     [10, 1, 10, 1, 1, 10, 1, 1, 10, 1, 1, 10, 1 ,1, 10],
                     [15, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11 ,11, 12]]*/
var mapTreasures = [Treasure(location: Location(row: 1, col: 1), num: 1),
                    Treasure(location: Location(row: 1, col: 3), num: 1),
                    Treasure(location: Location(row: 1, col: 5), num: 3),
                    Treasure(location: Location(row: 1, col: 9), num: 3),
                    Treasure(location: Location(row: 1, col: 13), num: 1),
                    Treasure(location: Location(row: 3, col: 1), num: 2),
                    Treasure(location: Location(row: 3, col: 4), num: 1),
                    Treasure(location: Location(row: 3, col: 6), num: 5),
                    Treasure(location: Location(row: 3, col: 12), num: 2),
                    Treasure(location: Location(row: 5, col: 1), num: 3),
                    Treasure(location: Location(row: 5, col: 5), num: 2),
                    Treasure(location: Location(row: 5, col: 8), num: 2),
                    Treasure(location: Location(row: 5, col: 11), num: 3),
                    Treasure(location: Location(row: 7, col: 1), num: 1),
                    Treasure(location: Location(row: 7, col: 3), num: 2),
                    Treasure(location: Location(row: 7, col: 6), num: 2),
                    Treasure(location: Location(row: 7, col: 9), num: 3),
                    Treasure(location: Location(row: 7, col: 13), num: 1),
                    Treasure(location: Location(row: 9, col: 1), num: 2),
                    Treasure(location: Location(row: 9, col: 4), num: 6),
                    Treasure(location: Location(row: 9, col: 11), num: 3)]
/*
                    Treasure(location: Location(row: 11, col: 1), num: 1),
                    Treasure(location: Location(row: 11, col: 3), num: 2),
                    Treasure(location: Location(row: 11, col: 6), num: 2),
                    Treasure(location: Location(row: 11, col: 9), num: 2),
                    Treasure(location: Location(row: 11, col: 12), num: 2)]*/
var treasureImgNum = [1, 2, 4, 5, 6, 7]
