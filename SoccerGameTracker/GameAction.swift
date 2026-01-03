import Foundation
import SwiftUI

enum ActionType: String, Codable {
    case teamGoal = "Team Goal"
    case teamGoalWithAssist = "Team Goal (Assist)"
    case unknownGoal = "Unknown Goal"
    case opponentGoal = "Opponent Goal"
    case yellowCard = "Yellow Card"
    case redCard = "Red Card"
    case save = "Save"
    case shot = "Shot"

    var icon: String {
        switch self {
        case .teamGoal, .teamGoalWithAssist:
            return "soccerball.circle.fill"
        case .unknownGoal:
            return "questionmark.circle.fill"
        case .opponentGoal:
            return "soccerball.circle"
        case .yellowCard:
            return "square.fill"
        case .redCard:
            return "square.fill"
        case .save:
            return "hand.raised.fill"
        case .shot:
            return "scope"
        }
    }

    var color: Color {
        switch self {
        case .teamGoal, .teamGoalWithAssist:
            return SemanticColors.success
        case .unknownGoal:
            return SemanticColors.textSecondary
        case .opponentGoal:
            return SemanticColors.error
        case .yellowCard:
            return Color.yellow
        case .redCard:
            return SemanticColors.error
        case .save:
            return SemanticColors.primary
        case .shot:
            return SemanticColors.textSecondary
        }
    }
}

struct GameAction: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let gameHalf: GameHalf
    let elapsedSeconds: Int
    let actionType: ActionType
    let playerId: UUID?
    let playerName: String
    let playerNumber: Int?
    let assistPlayerId: UUID?
    let assistPlayerName: String?
    let assistPlayerNumber: Int?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        gameHalf: GameHalf,
        elapsedSeconds: Int,
        actionType: ActionType,
        playerId: UUID? = nil,
        playerName: String,
        playerNumber: Int? = nil,
        assistPlayerId: UUID? = nil,
        assistPlayerName: String? = nil,
        assistPlayerNumber: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.gameHalf = gameHalf
        self.elapsedSeconds = elapsedSeconds
        self.actionType = actionType
        self.playerId = playerId
        self.playerName = playerName
        self.playerNumber = playerNumber
        self.assistPlayerId = assistPlayerId
        self.assistPlayerName = assistPlayerName
        self.assistPlayerNumber = assistPlayerNumber
    }

    func timeString() -> String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func displayDescription() -> String {
        switch actionType {
        case .teamGoal:
            if let number = playerNumber {
                return "#\(number) \(playerName) scored"
            }
            return "\(playerName) scored"

        case .teamGoalWithAssist:
            var description = ""
            if let number = playerNumber {
                description = "#\(number) \(playerName) scored"
            } else {
                description = "\(playerName) scored"
            }

            if let assistName = assistPlayerName {
                if let assistNumber = assistPlayerNumber {
                    description += " (assist: #\(assistNumber) \(assistName))"
                } else {
                    description += " (assist: \(assistName))"
                }
            }
            return description

        case .unknownGoal:
            return "Unknown player scored"

        case .opponentGoal:
            return "\(playerName) scored"

        case .yellowCard:
            if let number = playerNumber {
                return "#\(number) \(playerName) - Yellow Card"
            }
            return "\(playerName) - Yellow Card"

        case .redCard:
            if let number = playerNumber {
                return "#\(number) \(playerName) - Red Card"
            }
            return "\(playerName) - Red Card"

        case .save:
            if let number = playerNumber {
                return "#\(number) \(playerName) - Save"
            }
            return "\(playerName) - Save"

        case .shot:
            if let number = playerNumber {
                return "#\(number) \(playerName) - Shot"
            }
            return "\(playerName) - Shot"
        }
    }
}
