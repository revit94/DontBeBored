//
//  TabBarView.swift
//  DontBeBored
//
//  Created by reztsov on 7/22/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI
import UIKit

struct TabBarView: View {
    @State var selectedTab = Tab.randomActivity
    @ObservedObject var sercice = ActivitiesService()
    @EnvironmentObject var store: ActivityStore

    init() {
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
    }

    enum Tab: Int {
        case randomActivity
        case myActivities

        var title: String {
            switch self {
            case .randomActivity: return "Activity"
            case .myActivities: return "My Activities"
            }
        }

        var imageName: String {
            switch self {
                case .randomActivity: return "shuffle"
                case .myActivities: return "rectangle.stack.person.crop.fill"
            }
        }
    }

    func tabBarItem(title: String, imageName: String) -> some View {
        VStack {
            Image(systemName: imageName)
                .imageScale(.large)
            Text(title)
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RandomActivityView(activitiesService: sercice).tabItem {
                tabBarItem(title: Tab.randomActivity.title, imageName: Tab.randomActivity.imageName)
            }.tag(Tab.randomActivity)
            .background(Color.mineShaft)
            .edgesIgnoringSafeArea(.top)
            .environmentObject(store)

            MyActivities().tabItem {
                tabBarItem(title: Tab.myActivities.title, imageName: Tab.myActivities.imageName)
            }.tag(Tab.myActivities)
            .background(Color.mineShaft)
            .environmentObject(store)
        }
        .edgesIgnoringSafeArea(.top)
        .accentColor(Color.gold)
    }
}

#if DEBUG
struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
#endif
