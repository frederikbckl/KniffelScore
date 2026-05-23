import Foundation

struct Player: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var scores: [String: Int]

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.scores = [:]
    }
}

struct Game: Codable {
    var players: [Player]
    var currentPlayerIndex: Int

    init(players: [Player]) {
        self.players = players
        self.currentPlayerIndex = 0
    }

    var currentPlayer: Player { players[currentPlayerIndex] }

    var isFinished: Bool {
        players.allSatisfy { player in
            ScoreCategories.scoreable.allSatisfy { player.scores[$0.id] != nil }
        }
    }

    var currentRound: Int {
        let filled = players[currentPlayerIndex].scores.keys
            .filter { id in ScoreCategories.scoreable.contains { $0.id == id } }
            .count
        return min(filled + 1, 13)
    }

    mutating func enterScore(_ score: Int, for categoryId: String) {
        players[currentPlayerIndex].scores[categoryId] = score
    }

    mutating func advanceToNextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
}

enum CategoryKind: String, Codable, Equatable {
    case upperSection
    case fixedScore
    case freeScore
    case calculated
}

struct ScoreCategory: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let kind: CategoryKind
    let faceValue: Int?
    let fixedPoints: Int?
    let freeMin: Int?
    let freeMax: Int?

    init(
        id: String, name: String, kind: CategoryKind,
        faceValue: Int? = nil, fixedPoints: Int? = nil,
        freeMin: Int? = nil, freeMax: Int? = nil
    ) {
        self.id = id; self.name = name; self.kind = kind
        self.faceValue = faceValue; self.fixedPoints = fixedPoints
        self.freeMin = freeMin; self.freeMax = freeMax
    }
}
