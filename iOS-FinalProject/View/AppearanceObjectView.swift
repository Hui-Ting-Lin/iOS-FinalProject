//
//  AppearanceObjectView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/25.
//

import SwiftUI

struct AppearanceObjectView: View {
    var color: Color
    var imageName: String
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color(red: 175/255, green: 222/255, blue: 220/255))
                .frame(width: UIScreen.screenWidth/5*0.59, height: UIScreen.screenWidth/5*0.59)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .colorMultiply(color)
                .frame(width: 80, height: 80, alignment: .center)
        }
    }
}
