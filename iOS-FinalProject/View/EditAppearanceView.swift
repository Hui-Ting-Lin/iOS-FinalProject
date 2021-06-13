//
//  EditAppearanceView.swift
//  iOS-FinalProject
//
//  Created by Chase on 2021/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseStorageSwift
import FirebaseFirestore
import FirebaseFirestoreSwift

struct EditAppearanceView: View {
    @State private var uiImage: UIImage?
    @State private var currentObjectIndex = 0
    @EnvironmentObject var gameObject: GameObject
    @EnvironmentObject var appearanceObject: AppearanceObject
    @EnvironmentObject var firestoreData: FirestoreData
    
    var AppearancePreview: some View {
        ZStack{
            Image("body\(appearanceObject.chooseIndex[0])")
            Image("hair\(appearanceObject.chooseIndex[1])")
                .colorMultiply(appearanceObject.multiColor[1])
                .offset(x: 0, y: -35)
            Image("eyes\(appearanceObject.chooseIndex[2])")
                .offset(x: 0, y: -60)
            Image("accessories\(appearanceObject.chooseIndex[3])")
                .offset(x: 0, y: -35)
            Image("clothing\(appearanceObject.chooseIndex[4])")
                .colorMultiply(appearanceObject.multiColor[4])
                .offset(x: 0, y: 90)
            Image("nose\(appearanceObject.chooseIndex[5])")
                .offset(x: 0, y: -40)
            Image("mouth\(appearanceObject.chooseIndex[6])")
                .offset(x: 0, y: 10)
            Image("glasses\(appearanceObject.chooseIndex[7])")
                .offset(x: 0, y: -60)
            Image("facialHair\(appearanceObject.chooseIndex[8])")
                .colorMultiply(appearanceObject.multiColor[8])
                .offset(x: 0, y: 34)
        }
        
    }
    var body: some View {
        ZStack{
            Color(red: 199/255, green: 232/255, blue: 243/255)
                .ignoresSafeArea()
            HStack{
                ZStack{
                    AppearancePreview
                    RandomAppearanceBtn().environmentObject(appearanceObject)
                        .offset(x: UIScreen.screenWidth/7*1.2, y: -UIScreen.screenHeight*0.4)
                }
                .frame(width: UIScreen.screenWidth/7*2.8, height: UIScreen.screenHeight*0.9, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                //.background(Color(red: 240/255, green: 247/255, blue: 238/255))
                
                ZStack{
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color(red: 255/255, green: 255/255, blue: 232/255))
                        .overlay(
                            
                            MenuView(chooseObject: $appearanceObject.chooseIndex[currentObjectIndex], selectedColor: $appearanceObject.multiColor[currentObjectIndex], objectName: appearanceObject.objectNames[currentObjectIndex], objectCount: appearanceObject.objectCounts[currentObjectIndex])
                        )
                        .frame(width: UIScreen.screenWidth/5*2, height: UIScreen.screenHeight*0.9)
                }
                
                ObjectsSelection(currentObjectIndex: $currentObjectIndex)
                Button(action: {
                    uiImage = AppearancePreview.snapshot()
                    gameObject.userImg = Image(uiImage: uiImage!)
                    UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
                    
                    uploadPhoto(image: uiImage!){ result in
                        switch result{
                        case .success(let url):
                            setUserPhoto(url: url)
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                    gameObject.currentState = .profile
                    
                }, label: {
                    Text("FIN")
                })
                
            }
            Button(action: {gameObject.currentState = .profile
            }){
                Image("previous")
                    .resizable()
                    .frame(width: UIScreen.screenHeight*0.1, height: UIScreen.screenHeight*0.1)
                
            }
            .offset(x: -UIScreen.screenWidth*0.45, y: -UIScreen.screenHeight*0.4)
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping(Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.9){
            fileReference.putData(data, metadata: nil){ result in
                switch result{
                case .success(_):
                    fileReference.downloadURL{ result in
                        switch result{
                        case .success(let url):
                            completion(.success(url))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                        
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
                
                
            }
        }
        
    }
    
    func setUserPhoto(url: URL){
        firestoreData.user.userInfo.image = url.absoluteString
        firestoreData.updateUser()
    }
    
    
}



struct EditAppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        
        EditAppearanceView()
            .previewLayout(.fixed(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
        
        
    }
}
struct RandomAppearanceBtn: View{
    @EnvironmentObject var appearanceObject: AppearanceObject
    var body: some View{
        Button(action: {
            for i in 0..<9{
                appearanceObject.chooseIndex[i] = Int.random(in: 0..<appearanceObject.objectCounts[i])
            }
        }){
            Image("dices")
                .resizable()
                .frame(width: UIScreen.screenHeight*0.08, height: UIScreen.screenHeight*0.08)
        }
    }
}
struct MenuView: View {
    @Binding var chooseObject: Int
    @Binding var selectedColor: Color
    var objectName: String
    var objectCount: Int
    var body: some View {
        ScrollView(.vertical){
            VStack{
                ForEach(0..<(objectCount%3 == 0 ? objectCount/3 : objectCount/3+1), id: \.self){ (indexI) in
                    HStack(alignment: .top, spacing: 5){
                        ForEach(0..<3){ (indexJ) in
                            if(indexI*3+indexJ < objectCount){
                                Button(action: {
                                    chooseObject = indexI*3+indexJ
                                }){
                                    AppearanceObjectView(color: selectedColor, imageName: "\(objectName)\(indexI*3+indexJ)")
                                }
                            }
                            else{
                                Spacer()
                            }
                        }
                    }
                }
                if(objectName == "hair" || objectName == "clothing" || objectName == "facialHair"){
                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                }
            }
        }
        .frame(width: UIScreen.screenWidth/5*1.8, height: UIScreen.screenHeight*0.85)
    }
}

struct ObjectsSelection: View {
    @Binding var currentObjectIndex: Int
    @State private var appearanceObject = AppearanceObject()
    var body: some View {
        VStack{
            ForEach(0..<appearanceObject.objectNames.count){ (index) in
                Button(action: {currentObjectIndex = index
                }){
                    Rectangle()
                        .fill(Color(red: 175/255, green: 222/255, blue: 220/255))
                        .frame(width: 30, height: 30, alignment: .center)
                        .overlay(
                            Image("\(appearanceObject.objectNames[index])_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30, alignment: .center)
                        )
                }
                
            }
        }
        
    }
}


