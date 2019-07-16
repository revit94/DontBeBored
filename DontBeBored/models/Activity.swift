//
//  Activity.swift
//  DontBeBored
//
//  Created by reztsov on 7/23/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI
import CoreData

enum ActivityType: String, CaseIterable, Codable {
    case education
    case recreational
    case social
    case diy
    case charity
    case cooking
    case relaxation
    case music
    case busywork

    var color: Color {
        switch self {
        case .education: return Color.burntSienna
        case .recreational: return Color.mint
        case .social: return Color.hotPink
        case .diy: return Color.pewter
        case .charity: return Color.chiliPeper
        case .cooking: return Color.blueGreen
        case .relaxation: return Color.blueGrotto
        case .music: return Color.lilac
        case .busywork: return Color.champagne
        }
    }

    var iconName: String {
        switch self {
        case .education: return "doc.text.magnifyingglass"
        case .recreational: return "gamecontroller"
        case .social: return "person.and.person"
        case .diy: return "hammer"
        case .charity: return "heart.circle"
        case .cooking: return "tuningfork"
        case .relaxation: return "bed.double"
        case .music: return "guitars"
        case .busywork: return "ant"
        }
    }
}

extension ActivityType: Identifiable {
    var id: String {
        self.rawValue
    }
}

struct Activity {
    let key: String
    let activity: String
    let accessibility: Float
    let type: ActivityType
    let participants: Int
    let price: Float
    let link: String

    init(managedObject: ActivityData) {
        self.key = managedObject.key
        self.participants = managedObject.participants.intValue
        self.accessibility = managedObject.accessibility.floatValue
        self.type = ActivityType(rawValue: managedObject.type)!
        self.price = managedObject.price.floatValue
        self.link = managedObject.link
        self.activity = managedObject.activity
    }

    init(key: String,
         activity: String,
         accessibility: Float,
         type: ActivityType,
         participants: Int,
         price: Float,
         link: String) {
        self.key = key
        self.participants = participants
        self.accessibility = accessibility
        self.type = type
        self.price = price
        self.link = link
        self.activity = activity
    }
}

extension Activity: Equatable {}
extension Activity: Codable {}
extension Activity: Identifiable {
    var id: String {
        return key
    }
}

let sampleActivity = Activity(key: "1000000",
                              activity: "Sample of activity for test purposes. Test it very precisely.",
                              accessibility: 0.1,
                              type: ActivityType.relaxation,
                              participants: 1,
                              price: 0.3,
                              link: "")
