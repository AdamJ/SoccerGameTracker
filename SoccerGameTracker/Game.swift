import Foundation
import Combine

class Game: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var ourTeamName: String
    @Published var opponentName: String
    @Published var isHomeTeam: Bool
    @Published var gameDate: Date
    @Published var location: String
    @Published var durationInSeconds: Int
    @Published var ourScore: Int
    @Published var opponentScore: Int
    @Published var playerStats: [PlayerStats]
    @Published var currentHalf: GameHalf
    @Published var unknownGoals: Int = 0 // Track goals with unknown scorer
    @Published var remainingSeconds: Int
    @Published var isTimerRunning = false
    @Published var actions: [GameAction] = []
    private var timerCancellable: AnyCancellable?

    init(ourTeamName: String, opponentName: String, isHomeTeam: Bool, gameDate: Date, location: String, roster: [Player], durationInSeconds: Int) {
        self.id = UUID()
        self.ourTeamName = ourTeamName
        self.opponentName = opponentName
        self.isHomeTeam = isHomeTeam
        self.gameDate = gameDate
        self.location = location
        self.durationInSeconds = durationInSeconds
        self.remainingSeconds = durationInSeconds
        self.ourScore = 0
        self.opponentScore = 0
        self.currentHalf = .first
        self.playerStats = roster.map { player in
            PlayerStats(id: player.id, name: player.name, number: player.number, position: player.position, isSubstitute: player.isSubstitute)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, ourTeamName, opponentName, isHomeTeam, gameDate, location, durationInSeconds, ourScore, opponentScore, playerStats, remainingSeconds, currentHalf, unknownGoals, actions
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        ourTeamName = (try? container.decode(String.self, forKey: .ourTeamName)) ?? "HOME"
        opponentName = try container.decode(String.self, forKey: .opponentName)
        isHomeTeam = (try? container.decode(Bool.self, forKey: .isHomeTeam)) ?? true
        gameDate = try container.decode(Date.self, forKey: .gameDate)
        location = try container.decode(String.self, forKey: .location)
        durationInSeconds = try container.decode(Int.self, forKey: .durationInSeconds)
        ourScore = try container.decode(Int.self, forKey: .ourScore)
        opponentScore = try container.decode(Int.self, forKey: .opponentScore)
        playerStats = try container.decode([PlayerStats].self, forKey: .playerStats)
        remainingSeconds = try container.decode(Int.self, forKey: .remainingSeconds)
        currentHalf = try container.decode(GameHalf.self, forKey: .currentHalf)
        unknownGoals = (try? container.decode(Int.self, forKey: .unknownGoals)) ?? 0
        actions = (try? container.decode([GameAction].self, forKey: .actions)) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ourTeamName, forKey: .ourTeamName)
        try container.encode(opponentName, forKey: .opponentName)
        try container.encode(isHomeTeam, forKey: .isHomeTeam)
        try container.encode(gameDate, forKey: .gameDate)
        try container.encode(location, forKey: .location)
        try container.encode(durationInSeconds, forKey: .durationInSeconds)
        try container.encode(ourScore, forKey: .ourScore)
        try container.encode(opponentScore, forKey: .opponentScore)
        try container.encode(playerStats, forKey: .playerStats)
        try container.encode(remainingSeconds, forKey: .remainingSeconds)
        try container.encode(currentHalf, forKey: .currentHalf)
        try container.encode(unknownGoals, forKey: .unknownGoals)
        try container.encode(actions, forKey: .actions)
    }

    // --- Timer Logic ---
    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    func stopTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
    }
    func endHalf() {
        stopTimer()
        if currentHalf == .first {
            self.remainingSeconds = self.durationInSeconds
            self.currentHalf = .second
        }
    }
    func timeString() -> String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // --- Action Logging ---
    func logAction(
        actionType: ActionType,
        playerId: UUID? = nil,
        playerName: String,
        playerNumber: Int? = nil,
        assistPlayerId: UUID? = nil,
        assistPlayerName: String? = nil,
        assistPlayerNumber: Int? = nil
    ) {
        // Calculate elapsed seconds (time into current half)
        let elapsedSeconds = durationInSeconds - remainingSeconds

        let action = GameAction(
            timestamp: Date(),
            gameHalf: currentHalf,
            elapsedSeconds: elapsedSeconds,
            actionType: actionType,
            playerId: playerId,
            playerName: playerName,
            playerNumber: playerNumber,
            assistPlayerId: assistPlayerId,
            assistPlayerName: assistPlayerName,
            assistPlayerNumber: assistPlayerNumber
        )

        actions.append(action)
    }

    func removeAction(_ action: GameAction) {
        // Remove the action from the array
        actions.removeAll { $0.id == action.id }

        // Decrement corresponding stats based on action type
        switch action.actionType {
        case .teamGoal:
            // Decrement player goals and team score
            if let playerId = action.playerId,
               let playerIndex = playerStats.firstIndex(where: { $0.id == playerId }) {
                playerStats[playerIndex].goals = max(0, playerStats[playerIndex].goals - 1)
            }
            ourScore = max(0, ourScore - 1)

        case .teamGoalWithAssist:
            // Decrement player goals, team score, and assist
            if let playerId = action.playerId,
               let playerIndex = playerStats.firstIndex(where: { $0.id == playerId }) {
                playerStats[playerIndex].goals = max(0, playerStats[playerIndex].goals - 1)
            }
            if let assistId = action.assistPlayerId,
               let assistIndex = playerStats.firstIndex(where: { $0.id == assistId }) {
                playerStats[assistIndex].assists = max(0, playerStats[assistIndex].assists - 1)
            }
            ourScore = max(0, ourScore - 1)

        case .unknownGoal:
            // Decrement unknown goals and team score
            unknownGoals = max(0, unknownGoals - 1)
            ourScore = max(0, ourScore - 1)

        case .opponentGoal:
            // Decrement opponent score
            opponentScore = max(0, opponentScore - 1)

        case .yellowCard:
            // Decrement yellow cards
            if let playerId = action.playerId,
               let playerIndex = playerStats.firstIndex(where: { $0.id == playerId }) {
                playerStats[playerIndex].yellowCards = max(0, playerStats[playerIndex].yellowCards - 1)
            }

        case .redCard:
            // Decrement red cards
            if let playerId = action.playerId,
               let playerIndex = playerStats.firstIndex(where: { $0.id == playerId }) {
                playerStats[playerIndex].redCards = max(0, playerStats[playerIndex].redCards - 1)
            }

        case .save:
            // Decrement saves
            if let playerId = action.playerId,
               let playerIndex = playerStats.firstIndex(where: { $0.id == playerId }) {
                playerStats[playerIndex].saves = max(0, playerStats[playerIndex].saves - 1)
            }

        case .shot:
            // Decrement shots
            if let playerId = action.playerId,
               let playerIndex = playerStats.firstIndex(where: { $0.id == playerId }) {
                playerStats[playerIndex].totalShots = max(0, playerStats[playerIndex].totalShots - 1)
            }
        }
    }
}
