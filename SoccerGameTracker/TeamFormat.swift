import Foundation

enum TeamFormat: String, CaseIterable, Codable {
    case fiveVFive = "5v5"
    case sevenVSeven = "7v7"
    case elevenVEleven = "11v11"

    var displayName: String {
        return self.rawValue
    }

    var maxPlayers: Int {
        switch self {
        case .fiveVFive:
            return 5
        case .sevenVSeven:
            return 7
        case .elevenVEleven:
            return 11
        }
    }

    var description: String {
        switch self {
        case .fiveVFive:
            return "5 players per side"
        case .sevenVSeven:
            return "7 players per side"
        case .elevenVEleven:
            return "11 players per side"
        }
    }
}
