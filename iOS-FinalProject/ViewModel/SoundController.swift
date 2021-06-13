//
//  SoundController.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/6/13.
//

//
//  ViewController.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/22.
//

import SwiftUI
import AVFoundation

class SoundController: ObservableObject{
    @Published var dingMusic: AVPlayer = AVPlayer.dingPlayer
    @Published var dieMusic: AVPlayer = AVPlayer.diePlayer
    @Published var gameStartMusic: AVPlayer = AVPlayer.gameStartPlayer
    @Published var winMusic: AVPlayer = AVPlayer.winPlayer
    @Published var loseMusic: AVPlayer = AVPlayer.losePlayer
    @Published var poyoMusic: AVPlayer = AVPlayer.poyoPlayer
    
    @Published var isStopBackground = false
    @Published var isStopSound = false
    
    func playLobbyMusic(){
        AVPlayer.playLobbyMusic()
    }
    func playWaitingMusic(){
        AVPlayer.playWaitingMusic()
    }
    func playGameMusic(){
        AVPlayer.playGameMusic()
    }
    func playWinMusic(){
        winMusic.playFromStart()
    }
    func playLoseMusic(){
        loseMusic.playFromStart()
    }
    func playGameStartMusic(){
        gameStartMusic.playFromStart()
    }
    func playDingMusic(){
        dingMusic.playFromStart()
    }
    func playDieMusic(){
        dieMusic.playFromStart()
    }
    func playPoyoMusic(){
        poyoMusic.playFromStart()
    }
    
    
    func stopBackgroundMusic(){
        AVPlayer.queuePlayer.volume = 0
        self.isStopBackground = true
    }
    
    func stopSound(){
        winMusic.volume = 0
        loseMusic.volume = 0
        gameStartMusic.volume = 0
        dieMusic.volume = 0
        dingMusic.volume = 0
        poyoMusic.volume = 0
        self.isStopSound = true
    }
    
    func playBackgroundMusic(){
        AVPlayer.queuePlayer.volume = 1
        self.isStopBackground = false
    }
    
    func playSound(){
        winMusic.volume = 1
        loseMusic.volume = 1
        gameStartMusic.volume = 1
        dieMusic.volume = 1
        dingMusic.volume = 1
        poyoMusic.volume = 1
        self.isStopSound = false
    }
    
    func toogleSound(){
        if(isStopSound){
            playSound()
        }
        else{
            stopSound()
        }
        
    }
    
    func toogleBackground(){
        if(isStopBackground){
            playBackgroundMusic()
        }
        else{
            stopBackgroundMusic()
        }
    }
    
}

