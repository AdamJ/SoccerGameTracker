import Foundation

enum GameHalf: String, CaseIterable, Codable {
    case first = "First Half"
    case second = "Second Half"
    
    var displayName: String {
        return self.rawValue
    }
    
    var shortName: String {
        switch self {
        case .first:
            return "1st"
        case .second:
            return "2nd"
        }
    }
}
