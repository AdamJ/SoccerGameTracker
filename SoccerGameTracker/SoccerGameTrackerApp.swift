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

#if DEBUG
final class PreviewManagers: ObservableObject {
    let rosterManager: RosterManager
    let gameManager: GameManager
    let historyManager: GameHistoryManager

    init(populated: Bool) {
        rosterManager = RosterManager()
        gameManager = GameManager()
        historyManager = GameHistoryManager()

        if populated {
            // 11-player roster
            rosterManager.roster = [
                Player(name: "Alex Morgan", number: 1, position: .goalkeeper),
                Player(name: "Ben Carter", number: 24, position: .defender),
                Player(name: "Carlos Vega", number: 3, position: .defender),
                Player(name: "Diego Ramos", number: 40, position: .defender),
                Player(name: "Ethan Park", number: 5, position: .defender),
                Player(name: "Felix Hart", number: 62, position: .midfielder),
                Player(name: "George Li", number: 7, position: .midfielder),
                Player(name: "Hannah Kim", number: 88, position: .midfielder),
                Player(name: "Ivy Smith", number: 19, position: .midfielder),
                Player(name: "Jack Turner", number: 10, position: .forward),
                Player(name: "Liam Young", number: 11, position: .forward),
                Player(name: "Arnold Yount", number: 18, position: .substitute),
            ]
            rosterManager.homeTeamName = "TIGERS"

            // Active game for populated preview
            let activeGame = Game(ourTeamName: "Hawks", opponentName: "Rivals", isHomeTeam: true, gameDate: Date(), location: "United Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            activeGame.ourScore = 2
            activeGame.opponentScore = 1
            if activeGame.playerStats.indices.contains(8) { activeGame.playerStats[8].goals = 1 }
            if activeGame.playerStats.indices.contains(0) { activeGame.playerStats[0].saves = 2 }
            gameManager.currentGame = activeGame

            // Multiple past games in history
            let past1 = Game(ourTeamName: "Hawks", opponentName: "Eagles", isHomeTeam: false, gameDate: Date().addingTimeInterval(-86400 * 3), location: "Away Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past1.ourScore = 3
            past1.opponentScore = 2
            if past1.playerStats.indices.contains(6) { past1.playerStats[6].goals = 2 }
            if past1.playerStats.indices.contains(5) { past1.playerStats[5].assists = 1 }

            let past2 = Game(ourTeamName: "Hawks", opponentName: "Lions", isHomeTeam: true, gameDate: Date().addingTimeInterval(-86400 * 10), location: "United Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past2.ourScore = 1
            past2.opponentScore = 1
            if past2.playerStats.indices.contains(2) { past2.playerStats[2].saves = 1 }

            let past3 = Game(ourTeamName: "Hawks", opponentName: "Panthers", isHomeTeam: true, gameDate: Date().addingTimeInterval(-86400 * 30), location: "Neutral", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past3.ourScore = 0
            past3.opponentScore = 2
            if past3.playerStats.indices.contains(0) { past3.playerStats[0].saves = 4 }

            let past4 = Game(ourTeamName: "Hawks", opponentName: "Wolves", isHomeTeam: false, gameDate: Date().addingTimeInterval(-86400 * 60), location: "Away Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past4.ourScore = 4
            past4.opponentScore = 0
            if past4.playerStats.indices.contains(9) { past4.playerStats[9].goals = 2 }
            if past4.playerStats.indices.contains(10) { past4.playerStats[10].assists = 1 }
            if past4.playerStats.indices.contains(0) { past4.playerStats[0].saves = 1 }

            historyManager.completedGames = [past1, past2, past3, past4]
        } else {
            // Empty / fresh install
            rosterManager.roster = []
            rosterManager.homeTeamName = "United"
            historyManager.completedGames = []
        }

        rosterManager.gameManager = gameManager
    }
}

struct PopulatedPreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: true)
    var body: some View {
        ContentView()
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

struct EmptyPreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: false)
    var body: some View {
        ContentView()
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

// New preview: show the live GameTrackerView directly
struct LiveGamePreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: true)

    var body: some View {
        // Create an active game using the preview roster so the tracker shows populated player stats
        let activeGame = Game(ourTeamName: "Hawks", opponentName: "Rivals", isHomeTeam: true, gameDate: Date(), location: "Home Field", roster: managers.rosterManager.roster, durationInSeconds: 25 * 60)
        activeGame.ourScore = 2
        activeGame.opponentScore = 1
        if activeGame.playerStats.indices.contains(8) { activeGame.playerStats[8].goals = 1 }
        if activeGame.playerStats.indices.contains(0) { activeGame.playerStats[0].saves = 2 }

        return GameTrackerView(game: activeGame)
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

// Preview: show the GameHistoryView directly
struct GameHistoryPreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: true)
    var body: some View {
        GameHistoryView()
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

struct SoccerTrackerApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PopulatedPreviewView()
                .previewDisplayName("Populated — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")

            LiveGamePreviewView()
                .previewDisplayName("Live Game — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")

            EmptyPreviewView()
                .previewDisplayName("Empty — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")

            GameHistoryPreviewView()
                .previewDisplayName("Game History — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")
//            PopulatedPreviewView()
//                .previewDisplayName("Populated — iPad Pro 11-inch (M4)")
//                .previewDevice("iPad Pro 11-inch (M4)")
//            EmptyPreviewView()
//                .previewDisplayName("Empty — iPad Pro 11-inch (M4)")
//                .previewDevice("iPad Pro 11-inch (M4)")
        }
    }
}

#endif
