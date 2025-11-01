import Foundation
import Combine

class Game: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var opponentName: String
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
    private var timerCancellable: AnyCancellable?

    init(opponentName: String, gameDate: Date, location: String, roster: [Player], durationInSeconds: Int) {
        self.id = UUID()
        self.opponentName = opponentName
        self.gameDate = gameDate
        self.location = location
        self.durationInSeconds = durationInSeconds
        self.remainingSeconds = durationInSeconds
        self.ourScore = 0
        self.opponentScore = 0
        self.currentHalf = .first
        self.playerStats = roster.map { player in
            PlayerStats(id: player.id, name: player.name, number: player.number, position: player.position)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, opponentName, gameDate, location, durationInSeconds, ourScore, opponentScore, playerStats, remainingSeconds, currentHalf, unknownGoals
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        opponentName = try container.decode(String.self, forKey: .opponentName)
        gameDate = try container.decode(Date.self, forKey: .gameDate)
        location = try container.decode(String.self, forKey: .location)
        durationInSeconds = try container.decode(Int.self, forKey: .durationInSeconds)
        ourScore = try container.decode(Int.self, forKey: .ourScore)
        opponentScore = try container.decode(Int.self, forKey: .opponentScore)
        playerStats = try container.decode([PlayerStats].self, forKey: .playerStats)
        remainingSeconds = try container.decode(Int.self, forKey: .remainingSeconds)
        currentHalf = try container.decode(GameHalf.self, forKey: .currentHalf)
        unknownGoals = (try? container.decode(Int.self, forKey: .unknownGoals)) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(opponentName, forKey: .opponentName)
        try container.encode(gameDate, forKey: .gameDate)
        try container.encode(location, forKey: .location)
        try container.encode(durationInSeconds, forKey: .durationInSeconds)
        try container.encode(ourScore, forKey: .ourScore)
        try container.encode(opponentScore, forKey: .opponentScore)
        try container.encode(playerStats, forKey: .playerStats)
        try container.encode(remainingSeconds, forKey: .remainingSeconds)
        try container.encode(currentHalf, forKey: .currentHalf)
        try container.encode(unknownGoals, forKey: .unknownGoals)
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
}
