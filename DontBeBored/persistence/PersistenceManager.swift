//
//  PersistenceManager.swift
//  DontBeBored
//
//  Created by reztsov on 8/4/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import Foundation
import CoreData
import Combine

final class PersistenceManager {

    lazy var managedObjectContext: NSManagedObjectContext = {
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return self.persistentContainer.viewContext
    }()

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "DontBeBored")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Could not retrieve a persistent store description.")
        }

        // initialize the CloudKit schema
        let id = "iCloud.com.testnixsolutions.dontBeBored"
        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: id)
        description.cloudKitContainerOptions = options

        container.loadPersistentStores(completionHandler:
        { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
