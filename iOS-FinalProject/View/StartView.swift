//
//  StartView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/2.
//

import SwiftUI
import AVFoundation
import AppTrackingTransparency
struct StartView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var soundController: SoundController
    @State private var imgName = "treasure-2"
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            Image("map")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            HStack{
                Button(action: {
                    soundController.playPoyoMusic()
                    gameObject.currentState = .loading
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow)
                        .frame(width: UIScreen.screenHeight*0.7, height: UIScreen.screenHeight*0.15)
                        .overlay(
                            HStack{
                                Image(imgName)
                                    .resizable()
                                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                                Spacer()
                                Text("Game Start")
                                    .foregroundColor(.black)
                                    .font(.system(size: 22))
                                Spacer()
                                Image(imgName)
                                    .resizable()
                                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                            }
                        )
                    
                })
            }
            
        }
        .onAppear{
            soundController.playLobbyMusic()
            requestTracking()
        }
    }
}
func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .notDetermined:
                break
            case .restricted:
                break
            case .denied:
                break
            case .authorized:
                break
            @unknown default:
                break
            }
        }
    }

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
