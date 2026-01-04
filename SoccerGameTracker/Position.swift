import Foundation

enum Position: String, CaseIterable, Codable, Hashable {
    case goalkeeper = "Goalkeeper"
    case defender = "Defender"
    case midfielder = "Midfielder"
    case forward = "Forward"
    case substitute = "Substitute (SUB)"  // Deprecated: Use isSubstitute flag on Player instead

    /// Positions available for selection in UI (excludes deprecated substitute)
    static var displayPositions: [Position] {
        [.goalkeeper, .defender, .midfielder, .forward]
    }

    var abbreviation: String {
        switch self {
        case .goalkeeper:
            return "GK"
        case .defender:
            return "DEF"
        case .midfielder:
            return "MID"
        case .forward:
            return "FWD"
        case .substitute:
            return "SUB"
        }
    }

    var displayName: String {
        return self.rawValue
    }
}
