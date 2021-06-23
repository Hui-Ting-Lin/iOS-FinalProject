//
//  Extentions.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/5/5.
//

import SwiftUI
import AVFoundation
import GoogleMobileAds

extension Date {
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
            let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
            let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
            let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
            let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
            let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

            return (month: month, day: day, hour: hour, minute: minute, second: second)
        }
}


extension Image {
    func data(url: URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
                .resizable()
        }
        return self
            .resizable()
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
    func contains<T>(obj: T) -> Bool where T : Equatable {
            return self.filter({$0 as? T == obj}).count > 0
    }
}

extension Location{
    func sameLoc(location: Location) -> Bool{
        if(location.row == self.row && location.col == self.col){
            return true
        }
        else{
            return false
        }
    }
    
    func inRange() -> Bool{
        if(self.row >= 0 && self.row <= 12 && self.col >= 0 && self.col <= 14){
            return true
        }
        else{
            return false
        }
    }
    
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension AVPlayer {
    
    static var queuePlayer = AVQueuePlayer()

    static var playerLooper: AVPlayerLooper!
    
    
    static func playLobbyMusic() {
        queuePlayer.removeAllItems()
        guard let Url = Bundle.main.url(forResource: "lobbyMusic", withExtension: "mp3") else{fatalError("Failed to fin sound file.")}
        let item = AVPlayerItem(url: Url)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        queuePlayer.play()
    }
    
    
    static func playWaitingMusic() {
        queuePlayer.removeAllItems()
        guard let Url = Bundle.main.url(forResource: "waitingMusic", withExtension: "mp3") else{fatalError("Failed to fin sound file.")}
        let item = AVPlayerItem(url: Url)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        queuePlayer.play()
    }
    
    static func playGameMusic() {
        queuePlayer.removeAllItems()
        guard let Url = Bundle.main.url(forResource: "gameMusic", withExtension: "mp3") else{fatalError("Failed to fin sound file.")}
        let item = AVPlayerItem(url: Url)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        queuePlayer.play()
    }
    
    static let gameStartPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "gameStart", withExtension: "mov") else{fatalError("Failed to fin sound file.")}
        return AVPlayer(url: url)
    }()
    
    static let winPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "win", withExtension: "mov") else{fatalError("Failed to fin sound file.")}
        return AVPlayer(url: url)
    }()
    
    static let losePlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "lose", withExtension: "mov") else{fatalError("Failed to fin sound file.")}
        return AVPlayer(url: url)
    }()
    
    static let poyoPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "poyo", withExtension: "mp3") else{fatalError("Failed to fin sound file.")}
        return AVPlayer(url: url)
    }()
    
    static let diePlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "uhoh", withExtension: "mp3") else{fatalError("Failed to fin sound file.")}
        return AVPlayer(url: url)
    }()
    
    static let dingPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "mp3") else{fatalError("Failed to fin sound file.")}
        return AVPlayer(url: url)
    }()
    
    func playFromStart() {
        seek(to: .zero)
        play()
    }
    
}

extension UIViewController {
    static func getLastPresentedViewController() -> UIViewController? {
        let window = UIApplication.shared.windows.first {
            $0.isKeyWindow
        }
        var presentedViewController = window?.rootViewController
        while presentedViewController?.presentedViewController != nil {
            presentedViewController = presentedViewController?.presentedViewController
        }
        return presentedViewController
    }
}
/*
extension RewardedAdController: GADFullScreenContentDelegate{
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print(#function)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print(#function)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWith error: Error){
        print(#function, error)
    }
    
}
*/
