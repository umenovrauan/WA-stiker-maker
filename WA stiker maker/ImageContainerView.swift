//
//  ImageContainerView.swift
//  WA stiker maker
//
//  Created by Rauan Umenov on 17.12.2023.
//

import SwiftUI

let width: CGFloat = 108
let spacing: CGFloat = 20
struct ImageContainerView: View {
    var badgeText: String?
    var image: Image?
    var body: some View {
        ZStack(alignment: .topLeading){
            if image == nil {
                Image(systemName: "photo.badge.plus")
                    .imageScale(.large)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            }
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
            if let badgeText {
                Text(badgeText)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(4)
                    .background{
                        Circle().foregroundStyle(Color.accentColor)
                    }
                    .padding([.leading,.top],8)
            }
        }
        .frame(width: width, height: width)
        .overlay{
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, dash: [8]))
        }
    }
}

#Preview {
    VStack{
        ImageContainerView()
        ImageContainerView(badgeText: "12", image: Image("32bmlqyy6sd41"))
    }
}
