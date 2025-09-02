//
//  SoccerGameTrackerApp.swift
//  SoccerGameTracker
//
//  Created by Adam Jolicoeur on 9/2/25.
//

import SwiftUI

@main
struct SoccerGameTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
