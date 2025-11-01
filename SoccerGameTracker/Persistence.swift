//
//  Persistence.swift
//  SoccerGameTracker
//
//  Created by Adam Jolicoeur on 9/2/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Production error handling: log the error instead of crashing.
            let nsError = error as NSError
            print("Core Data preview save error: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SoccerGameTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Production error handling: log the error instead of crashing.
                print("Unresolved Core Data error: \(error), \(error.userInfo)")
                // Optionally, you could notify the user or take other action here.
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
