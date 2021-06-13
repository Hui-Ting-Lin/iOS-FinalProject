//
//  ProfileView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var firestoreData: FirestoreData
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            HStack{
                VStack{
                    gameObject.userImg
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenHeight * 0.6, height: UIScreen.screenHeight * 0.6)
                        .clipped()
                    
                    Button(action:{
                        gameObject.currentState = .editAppearance
                    }, label:{
                        Text("Edit appearance")
                    })
                }
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 255/255, green: 234/255, blue: 162/255))
                        //Color(red: 168/255, green: 218/255, blue: 220/255)
                        .overlay(
                            VStack{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(red: 255/255, green: 255/255, blue: 232/255))
                                    .overlay(
                                        Text("\(firestoreData.user.userInfo.name)")
                                            .bold()
                                    )
                                    .frame(width: UIScreen.screenWidth*0.58, height: UIScreen.screenHeight*0.1)
                                    .offset(y: UIScreen.screenHeight*0.03)
                                Spacer()
                                HStack{
                                    Spacer()
                                    CircleView(num: firestoreData.user.userInfo.playTimes, txt: NSLocalizedString("PlayTimes", comment: ""))
                                    Spacer()
                                    CircleView(num: firestoreData.user.userInfo.numberOfWins, txt: NSLocalizedString("Wins", comment: ""))
                                    Spacer()
                                    CircleView(num: evaluateTime(startDate: stringConvertDate(string: firestoreData.user.userInfo.registerTime), toDate: Date()), txt: NSLocalizedString("TotalDays", comment: ""))
                                    Spacer()
                                }
                                Spacer()
                                HistorysView(historys: firestoreData.user.historys)
                                
                            }
                        )
                        .frame(width: UIScreen.screenWidth/5*3, height: UIScreen.screenHeight*0.9)
                    
                }
            }
            Button(action: {gameObject.currentState = .home
            }){
                Image("previous")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                
            }
            .offset(x: -UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
        }
    }
    func stringConvertDate(string: String) -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale(identifier: "en_us")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let date = dateFormatter.date(from: string)
        return date!
    }
    func evaluateTime(startDate: Date, toDate: Date) -> Int{
        let timeInterval = toDate - startDate
        return timeInterval.day!
    }
}
struct CircleView: View {
    var num: Int
    var txt: String
    var body: some View {
        VStack{
            Circle()
                .fill(Color.red)
                .frame(width: UIScreen.screenWidth*0.1, height: UIScreen.screenWidth*0.1)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: UIScreen.screenWidth*0.08, height: UIScreen.screenWidth*0.08)
                        .overlay(
                            Image("\(txt)")
                                .resizable()
                                .frame(width: UIScreen.screenWidth*0.06, height: UIScreen.screenWidth*0.06)
                        )
                )
                
                .overlay(
                    Rectangle()
                        .fill(Color.yellow)
                        .overlay(
                            Text(txt)
                            
                        )
                        .frame(width: UIScreen.screenWidth*0.105, height: UIScreen.screenWidth*0.0205)//105
                        .offset(y: UIScreen.screenWidth*0.04)
                    
                )
            Text("\(num)")
        }
    }
    
}
struct HistorysView: View {
    var historys: [History]
    var body: some View {
        ScrollView(.vertical){
            VStack{
                HStack{
                    Text("Winner")
                        .frame(width: UIScreen.screenWidth*0.12, height: UIScreen.screenHeight*0.1)
                    Text("Time")
                        .frame(width: UIScreen.screenWidth*0.09, height: UIScreen.screenHeight*0.1)
                    Text("Date")
                        .frame(width: UIScreen.screenWidth*0.13, height: UIScreen.screenHeight*0.1)
                    Text("Result")
                        .frame(width: UIScreen.screenWidth*0.09, height: UIScreen.screenHeight*0.1)
                }
                ForEach(0..<historys.count){ index in
                    HStack{
                        Text("\(historys[index].winner)")
                            .frame(width: UIScreen.screenWidth*0.12, height: UIScreen.screenHeight*0.1)
                        Text("\(historys[index].spendTime)")
                            .frame(width: UIScreen.screenWidth*0.09, height: UIScreen.screenHeight*0.1)
                        Text("\(historys[index].timeStamp)")
                            .frame(width: UIScreen.screenWidth*0.13, height: UIScreen.screenHeight*0.1)
                        Text(historys[index].win ? "Win" : "Lose")
                            .frame(width: UIScreen.screenWidth*0.09, height: UIScreen.screenHeight*0.1)
                    }
                }
            }
        }
        .frame(width: UIScreen.screenWidth/5*2.8, height: UIScreen.screenHeight*0.4)
        .background(Color(red: 255/255, green: 255/255, blue: 232/255))
    }
    
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
