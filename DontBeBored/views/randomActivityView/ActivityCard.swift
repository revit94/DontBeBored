//
//  ActivityCard.swift
//  DontBeBored
//
//  Created by reztsov on 7/23/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI

struct ActivityCardStyle: ViewModifier {
    var color: Color?

    func body(content: Content) -> some View {
        let width = UIApplication.shared.windows.first!.bounds.width - 100
        return content
            .frame(width: width,
                   height: width)
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .overlay(RoundedRectangle(cornerRadius: 50).stroke(lineWidth: 2).foregroundColor((color ?? Color.ivory)))
            .background(
                RoundedRectangle(cornerRadius: 50, style: .circular)
                    .fill((color ?? Color.ivory))
            )
    }
}

extension View {
    func activityCardStyle(color: Color?) -> some View {
        return ModifiedContent(content: self, modifier: ActivityCardStyle(color: color))
    }
}

struct ActivityPlaceholderCard: View {
    private var placeholderRect: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray)
            .blur(radius: 3.0)
    }

     var body: some View {
        return GeometryReader { geometry in
            VStack {
                self.placeholderRect
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY - 15.0)
                    .frame(height: 20.0)

                self.placeholderRect
                    .position(x: geometry.frame(in: .local).midX - 40, y: geometry.frame(in: .local).midY - 15.0)
                    .frame(width: geometry.size.width - 80.0, height: 20.0)
                Spacer()
            }
        }
    }
}

struct ActivityDataCard: View {
    let activity: Activity

    var body: some View {
        VStack {
            Spacer()

            Text(activity.activity)
                .fontWeight(.heavy)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .foregroundColor(.charcoal)

            Divider().background(Color.charcoal)

            GeometryReader { geometry in
                HStack {
                    Image(systemName: self.activity.type.iconName).font(.system(size: 15)).foregroundColor(.mineShaft)
                    Text(self.activity.type.rawValue).font(.system(size: 15)).italic().foregroundColor(.mineShaft)
                }.position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).minY + 15)
            }
        }.frame(alignment: .center)
    }
}

struct ActivityCard: View {
    var activity: Activity?

    var body: some View {
        ZStack {
            if self.activity != nil {
                ActivityDataCard(activity: activity!)
            } else {
                ActivityPlaceholderCard()
            }
        }.activityCardStyle(color: activity?.type.color)
    }
}

#if DEBUG
struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: sampleActivity)
    }
}
#endif
