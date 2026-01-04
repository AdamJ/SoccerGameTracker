import Foundation
import Combine

class RosterManager: ObservableObject {
    @Published var roster: [Player] = [] { didSet { saveRoster() } }
    @Published var homeTeamName: String = "HOME" { didSet { saveHomeTeamName() } }
    @Published var teamFormat: TeamFormat = .elevenVEleven { didSet { saveTeamFormat() } }
    @Published var isHomeTeam: Bool = true { didSet { saveIsHomeTeam() } }
    private let rosterKey = "SoccerRoster"
    private let homeTeamNameKey = "SoccerHomeTeamName"
    private let teamFormatKey = "SoccerTeamFormat"
    private let isHomeTeamKey = "SoccerIsHomeTeam"
    weak var gameManager: GameManager?

    init() {
        loadRoster()
        loadHomeTeamName()
        loadTeamFormat()
        loadIsHomeTeam()
    }
    func addPlayer(name: String, number: Int, position: Position, isSubstitute: Bool? = nil) {
        // Use manual designation if provided, otherwise auto-assign based on lineup capacity
        let shouldBeSubstitute = isSubstitute ?? isStartingLineupFull()
        roster.append(Player(name: name, number: number, position: position, isSubstitute: shouldBeSubstitute))
    }
    func updatePlayer(_ player: Player) {
        if let index = roster.firstIndex(where: { $0.id == player.id }) {
            roster[index] = player
            gameManager?.syncPlayerToGame(player)
        }
    }
    func canAddGoalkeeper(ignoring playerID: UUID? = nil) -> Bool {
        // Only check STARTING lineup (not all players including substitutes)
        let otherStarters = starters.filter { $0.id != playerID }
        return !otherStarters.contains { $0.position == .goalkeeper }
    }
    
    func removePlayer(at offsets: IndexSet) {
        roster.remove(atOffsets: offsets)
    }

    // MARK: - Computed Properties

    /// Players in the starting lineup (not substitutes)
    var starters: [Player] {
        roster.filter { !$0.isSubstitute }
    }

    /// Players designated as substitutes
    var substitutes: [Player] {
        roster.filter { $0.isSubstitute }
    }

    /// Goalkeepers in the starting lineup
    var starterGoalkeepers: [Player] {
        roster.filter { $0.position == .goalkeeper && !$0.isSubstitute }
    }

    /// Check if the starting lineup has reached team format capacity
    func isStartingLineupFull() -> Bool {
        return starters.count >= teamFormat.maxPlayers
    }

    // MARK: - Goalkeeper Validation

    /// Check if deleting these players would remove the only starting goalkeeper
    func wouldRemoveOnlyGoalkeeper(removing players: [Player]) -> Bool {
        let startingGKs = starters.filter { $0.position == .goalkeeper }
        let deletingGKs = players.filter { $0.position == .goalkeeper && !$0.isSubstitute }

        // Would remove only GK if: exactly 1 starting GK exists AND we're deleting it
        return startingGKs.count == 1 && deletingGKs.count == 1
    }

    /// Check if moving this player to a new position requires a goalkeeper swap
    func requiresGoalkeeperSwap(for player: Player, newPosition: Position) -> Bool {
        // Only matters if:
        // 1. Player is currently a substitute
        // 2. New position is goalkeeper
        // 3. There's already a GK in starters
        guard player.isSubstitute && newPosition == .goalkeeper else {
            return false
        }

        let otherStarters = starters.filter { $0.id != player.id }
        return otherStarters.contains { $0.position == .goalkeeper }
    }

    /// Swap goalkeepers: move current starter GK to subs, move incoming GK to starters
    func swapGoalkeepers(incomingGK: Player) {
        // Find the current starting goalkeeper
        guard let currentGKIndex = roster.firstIndex(where: {
            $0.position == .goalkeeper && !$0.isSubstitute
        }) else {
            return
        }

        // Move current GK to subs
        roster[currentGKIndex].isSubstitute = true

        // Move incoming GK to starters
        if let incomingIndex = roster.firstIndex(where: { $0.id == incomingGK.id }) {
            roster[incomingIndex].isSubstitute = false
        }
    }

    private func saveRoster() { if let data = try? JSONEncoder().encode(roster) { UserDefaults.standard.set(data, forKey: rosterKey) } }
    private func loadRoster() {
        guard let data = UserDefaults.standard.data(forKey: rosterKey), var decoded = try? JSONDecoder().decode([Player].self, from: data) else { return }

        // Migration: Convert deprecated Position.substitute to isSubstitute flag
        var needsSave = false
        for i in 0..<decoded.count {
            if decoded[i].position == .substitute {
                decoded[i].position = .forward
                decoded[i].isSubstitute = true
                needsSave = true
            }
        }

        self.roster = decoded

        // Save migrated data immediately
        if needsSave {
            saveRoster()
        }
    }
    private func saveHomeTeamName() { UserDefaults.standard.set(homeTeamName, forKey: homeTeamNameKey) }
    private func loadHomeTeamName() {
        if let name = UserDefaults.standard.string(forKey: homeTeamNameKey) {
            homeTeamName = name
        }
    }

    private func saveTeamFormat() {
        if let data = try? JSONEncoder().encode(teamFormat) {
            UserDefaults.standard.set(data, forKey: teamFormatKey)
        }
    }

    private func loadTeamFormat() {
        guard let data = UserDefaults.standard.data(forKey: teamFormatKey),
              let decoded = try? JSONDecoder().decode(TeamFormat.self, from: data) else { return }
        self.teamFormat = decoded
    }

    private func saveIsHomeTeam() {
        UserDefaults.standard.set(isHomeTeam, forKey: isHomeTeamKey)
    }

    private func loadIsHomeTeam() {
        if UserDefaults.standard.object(forKey: isHomeTeamKey) != nil {
            isHomeTeam = UserDefaults.standard.bool(forKey: isHomeTeamKey)
        }
    }
}
