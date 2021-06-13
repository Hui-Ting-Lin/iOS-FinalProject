//
//  iOS_FinalProjectApp.swift
//  iOS-FinalProject
//
//  Created by User15 on 2021/4/14.
//

import SwiftUI
import Firebase
import FacebookCore

@main
struct iOS_FinalProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ViewController()
                .onOpenURL(perform: { url in
                    ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplication.OpenURLOptionsKey.annotation)
                })
        }
    }
}


