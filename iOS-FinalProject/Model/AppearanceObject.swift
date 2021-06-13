//
//  AppearenceObject.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/25.
//

import Foundation
import SwiftUI

class AppearanceObject: ObservableObject{
    var objectNames = ["body", "hair", "eyes", "accessories", "clothing", "nose", "mouth", "glasses", "facialHair"]
    var objectCounts = [5, 27, 8, 5, 7, 3, 13, 4, 9]
    @Published var chooseIndex = [Int](repeating: 0, count: 9)
    @Published var multiColor = [Color.white, Color.black, Color.white, Color.white, Color.green, Color.white, Color.white, Color.white, Color.black]
    var body = Object(name: "body", count: 5)
    var hair = Object(name: "hair", count: 27)
    var mouth = Object(name: "mouth", count: 13)
    var eyes = Object(name: "eyes", count: 8)
    var accessories = Object(name: "accessories", count: 5)
    var clothing = Object(name: "clothing", count: 7)
    var nose = Object(name: "nose", count: 3)
    var facialHair = Object(name: "facialHair", count: 9)
    var glasses = Object(name: "glasses", count: 4)

}

struct Object{
    var name: String
    var count: Int
}
