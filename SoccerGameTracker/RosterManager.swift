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
    func addPlayer(name: String, number: Int, position: Position) {
        roster.append(Player(name: name, number: number, position: position))
    }
    func updatePlayer(_ player: Player) {
        if let index = roster.firstIndex(where: { $0.id == player.id }) {
            roster[index] = player
            gameManager?.syncPlayerToGame(player)
        }
    }
    func canAddGoalkeeper(ignoring playerID: UUID? = nil) -> Bool {
        let otherPlayers = roster.filter { $0.id != playerID }
        return !otherPlayers.contains { $0.position == .goalkeeper }
    }
    
    func removePlayer(at offsets: IndexSet) {
        roster.remove(atOffsets: offsets)
    }
    private func saveRoster() { if let data = try? JSONEncoder().encode(roster) { UserDefaults.standard.set(data, forKey: rosterKey) } }
    private func loadRoster() {
        guard let data = UserDefaults.standard.data(forKey: rosterKey), let decoded = try? JSONDecoder().decode([Player].self, from: data) else { return }
        self.roster = decoded
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
