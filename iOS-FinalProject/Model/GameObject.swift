//
//  GameObject.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/22.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class GameObject: ObservableObject{
    enum CurrentState{
        case login, register, enterName, home, editAppearance, start, loading, profile, intoRoom, gameRoom, game, result, setting
    }
    
    @Published var currentState = CurrentState.start
    @Published var registerMethod = "facebook"
    @Published var userImg: Image = Image("defaultImg")
    
}

