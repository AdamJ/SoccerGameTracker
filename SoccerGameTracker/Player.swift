import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var number: Int
    var position: Position
    var isSubstitute: Bool

    init(id: UUID = UUID(), name: String, number: Int, position: Position, isSubstitute: Bool = false) {
        self.id = id
        self.name = name
        self.number = number
        self.position = position
        self.isSubstitute = isSubstitute
    }
}
