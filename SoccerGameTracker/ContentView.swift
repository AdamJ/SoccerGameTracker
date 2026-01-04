import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var rosterManager = RosterManager()
    @StateObject private var gameHistoryManager = GameHistoryManager()
    @StateObject private var gameManager = GameManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RosterView()
                .environmentObject(rosterManager)
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Roster")
                }
                .tag(0)
            
            GameSetupView()
                .environmentObject(rosterManager)
                .environmentObject(gameHistoryManager)
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("New Game")
                }
                .tag(1)
            
            GameHistoryView()
                .environmentObject(gameHistoryManager)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)
        }
        .onAppear {
            // Connect the managers so games are automatically saved to history
            gameManager.gameHistoryManager = gameHistoryManager
            rosterManager.gameManager = gameManager
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
