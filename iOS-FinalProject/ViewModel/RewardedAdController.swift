//
//  GADController.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/6/12.
//

import SwiftUI
import GoogleMobileAds

class RewardedAdController: NSObject{
    private var ad: GADRewardedAd?
    func loadAd(){
        print("load ad")
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request){ ad, error in
            if let error = error{
                print(error)
                return
            }
            print("success")
            ad?.fullScreenContentDelegate = self
            self.ad = ad
        }
    }
    func showAd(){
        print("show ad")
        if let ad = ad,
           let controller = UIViewController.getLastPresentedViewController(){
            ad.present(fromRootViewController: controller){
                print("獲得獎勵")
            }
        }
    }
}
