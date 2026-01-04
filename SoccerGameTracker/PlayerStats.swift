import Foundation

class PlayerStats: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    @Published var number: Int
    @Published var position: Position
    @Published var goals: Int = 0
    @Published var assists: Int = 0
    @Published var yellowCards: Int = 0
    @Published var redCards: Int = 0
    @Published var saves: Int = 0
    @Published var totalShots: Int = 0
    @Published var minutesPlayed: Int = 0
    @Published var isSubstituted: Bool = false
    @Published var isSubstitute: Bool = false  // Started game on the bench

    init(id: UUID, name: String, number: Int, position: Position, isSubstitute: Bool = false) {
        self.id = id
        self.name = name
        self.number = number
        self.position = position
        self.isSubstitute = isSubstitute
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, number, position, goals, assists, yellowCards, redCards, saves, totalShots, minutesPlayed, isSubstituted, isSubstitute
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        number = try container.decode(Int.self, forKey: .number)
        position = try container.decode(Position.self, forKey: .position)
        goals = try container.decode(Int.self, forKey: .goals)
        assists = try container.decode(Int.self, forKey: .assists)
        yellowCards = try container.decode(Int.self, forKey: .yellowCards)
        redCards = try container.decode(Int.self, forKey: .redCards)
        saves = try container.decode(Int.self, forKey: .saves)
        totalShots = (try? container.decode(Int.self, forKey: .totalShots)) ?? 0
        minutesPlayed = try container.decode(Int.self, forKey: .minutesPlayed)
        isSubstituted = try container.decode(Bool.self, forKey: .isSubstituted)
        isSubstitute = (try? container.decode(Bool.self, forKey: .isSubstitute)) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(position, forKey: .position)
        try container.encode(goals, forKey: .goals)
        try container.encode(assists, forKey: .assists)
        try container.encode(yellowCards, forKey: .yellowCards)
        try container.encode(redCards, forKey: .redCards)
        try container.encode(saves, forKey: .saves)
        try container.encode(totalShots, forKey: .totalShots)
        try container.encode(minutesPlayed, forKey: .minutesPlayed)
        try container.encode(isSubstituted, forKey: .isSubstituted)
        try container.encode(isSubstitute, forKey: .isSubstitute)
    }
    
    // MARK: - Stat Management
    func incrementGoals() {
        goals += 1
    }
    
    func decrementGoals() {
        if goals > 0 {
            goals -= 1
        }
    }
    
    func incrementAssists() {
        assists += 1
    }
    
    func decrementAssists() {
        if assists > 0 {
            assists -= 1
        }
    }
    
    func addYellowCard() {
        yellowCards += 1
    }
    
    func addRedCard() {
        redCards += 1
    }
    
    func addSave() {
        saves += 1
    }
}
