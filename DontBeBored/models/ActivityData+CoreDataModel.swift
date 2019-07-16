//
//  ActivityData+CoreDataModel.swift
//  DontBeBored
//
//  Created by reztsov on 8/4/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import Foundation
import CoreData

@objc(ActivityData)
public class ActivityData: NSManagedObject {

    public class func fetchRequest() -> NSFetchRequest<ActivityData> {
        return NSFetchRequest<ActivityData>(entityName: "ActivityData")
    }

    @NSManaged public var key: String
    @NSManaged public var link: String
    @NSManaged public var activity: String
    @NSManaged public var type: String
    @NSManaged public var accessibility: NSNumber
    @NSManaged public var price: NSNumber
    @NSManaged public var participants: NSNumber
    @NSManaged public var dateUpdated: Date
    @NSManaged public var isInProgress: Bool
    @NSManaged public var isCompleted: Bool

    static func create(activity: Activity, in context: NSManagedObjectContext) {
        let newData = ActivityData(context: context)
        newData.key = activity.key
        newData.link = activity.link
        newData.type = activity.type.rawValue
        newData.activity = activity.activity
        newData.accessibility = NSNumber(value: activity.accessibility)
        newData.price = NSNumber(value: activity.price)
        newData.participants = NSNumber(value: activity.participants)
        newData.dateUpdated = Date()
        newData.isInProgress = true
        newData.isCompleted = false
    }
}

extension ActivityData {

    static func allActivitiesFetchRequest() -> NSFetchRequest<ActivityData> {
        let request: NSFetchRequest<ActivityData> = ActivityData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateUpdated", ascending: false)]
        
        return request
    }

    static func completedActivitiesFetchRequest() -> NSFetchRequest<ActivityData> {
        let request: NSFetchRequest<ActivityData> = ActivityData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateUpdated", ascending: false)]
        let predicate = NSPredicate(format: "isCompleted == true")
        request.predicate = predicate

        return request
    }

    static func inProgressActivitiesFetchRequest() -> NSFetchRequest<ActivityData> {
        let request: NSFetchRequest<ActivityData> = ActivityData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateUpdated", ascending: false)]
        let predicate = NSPredicate(format: "isInProgress == true")
        request.predicate = predicate

        return request
    }
}
