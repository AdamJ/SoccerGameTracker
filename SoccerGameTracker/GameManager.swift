import Foundation

class GameManager: ObservableObject {
    @Published var currentGame: Game?
    weak var gameHistoryManager: GameHistoryManager?
    
    var isGameActive: Bool { currentGame != nil }
    var isRosterLocked: Bool {
        guard let game = currentGame else { return false }
        if game.currentHalf == .first { return true }
        if game.currentHalf == .second && game.isTimerRunning { return true }
        return false
    }
    
    func startGame(ourTeamName: String, opponentName: String, isHomeTeam: Bool, gameDate: Date, location: String, roster: [Player], durationInSeconds: Int) {
        currentGame = Game(ourTeamName: ourTeamName, opponentName: opponentName, isHomeTeam: isHomeTeam, gameDate: gameDate, location: location, roster: roster, durationInSeconds: durationInSeconds)
    }
    
    func endGame() {
        guard let game = currentGame else { return }
        game.stopTimer()
        
        // Save completed game to history
        gameHistoryManager?.saveGame(game)
        
        currentGame = nil
    }
    
    func syncPlayerToGame(_ player: Player) {
        guard let game = currentGame else { return }
        if let index = game.playerStats.firstIndex(where: { $0.id == player.id }) {
            game.playerStats[index].name = player.name
            game.playerStats[index].number = player.number
            game.playerStats[index].position = player.position
        }
    }
}
