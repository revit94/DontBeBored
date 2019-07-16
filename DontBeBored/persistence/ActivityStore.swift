//
//  ActivityStore.swift
//  DontBeBored
//
//  Created by reztsov on 8/4/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreData


final class ActivityStore: ObservableObject {

    private let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    public func add(_ activity: Activity) {
        ActivityData.create(activity: activity, in: persistenceManager.managedObjectContext)
        saveChanges()
    }

    public func toggleCompleted(_ activity: Activity) {
        guard let data = fetchObject(by: activity.key) else {
            return
        }

        data.isInProgress = data.isCompleted
        data.isCompleted = !data.isCompleted
        saveChanges()
    }

    public func delete(_ activity: Activity) {
        guard let data = fetchObject(by: activity.key) else {
            return
        }
        persistenceManager.managedObjectContext.delete(data)
        saveChanges()
    }

    public func saveChanges() {
        persistenceManager.saveContext()
    }

    private func fetchObject(by key: String) -> ActivityData? {
        let predicate = NSPredicate(format: "key == \(key)")
        let entityName = String(describing: ActivityData.self)
        let request = NSFetchRequest<ActivityData>(entityName: entityName)
        request.predicate = predicate

        do {
            let object = try persistenceManager.managedObjectContext.fetch(request)
            return object.first
        } catch {
            fatalError()
        }
    }
}
