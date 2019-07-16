//
//  BorderButton.swift
//  DontBeBored
//
//  Created by reztsov on 7/31/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI

struct BorderButton: View {
    let text: String
    let systemImageName: String
    let color: Color
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: systemImageName).foregroundColor(isOn ? .white : color)
                Text(text).foregroundColor(isOn ? .white : color)
            }
        })
        .frame(width: 100)
        .padding(10)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: isOn ? 0 : 1).foregroundColor(color))
        .background(isOn ? color : Color.clear)
    }
}

#if DEBUG
struct BorderButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BorderButton(text: "Add to wishlist",
                           systemImageName: "film",
                           color: .green,
                           isOn: false,
                           action: {

            })
            BorderButton(text: "Add to wishlist",
                           systemImageName: "film",
                           color: .blue,
                           isOn: true,
                           action: {

            })
        }
    }
}
#endif
