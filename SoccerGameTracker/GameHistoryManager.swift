import Foundation
import Combine

class GameHistoryManager: ObservableObject {
    @Published var completedGames: [Game] = []
    
    private let userDefaults = UserDefaults.standard
    private let gamesKey = "SavedGames"
    
    init() {
        loadGames()
    }
    
    func loadGames() {
        if let data = userDefaults.data(forKey: gamesKey),
           let games = try? JSONDecoder().decode([Game].self, from: data) {
            self.completedGames = games.sorted { $0.gameDate > $1.gameDate }
        }
    }
    
    func saveGame(_ game: Game) {
        game.stopTimer()
        completedGames.append(game)
        completedGames.sort { $0.gameDate > $1.gameDate }
        saveGames()
    }
    
    func deleteGames(at offsets: IndexSet) {
        completedGames.remove(atOffsets: offsets)
        saveGames()
    }
    
    private func saveGames() {
        if let data = try? JSONEncoder().encode(completedGames) {
            userDefaults.set(data, forKey: gamesKey)
        }
    }
}
