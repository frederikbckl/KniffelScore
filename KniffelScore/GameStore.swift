import Foundation
import Observation

@Observable
final class GameStore {
    var game: Game?

    private let saveKey = "kniffelGame_v1"
    private let lastPlayersKey = "kniffelLastPlayers_v1"

    private(set) var lastPlayerNames: [String] = []

    init() { load() }

    var hasSavedGame: Bool { game != nil }

    func startNewGame(playerNames: [String]) {
        game = Game(players: playerNames.map { Player(name: $0) })
        save()
    }

    func enterScore(_ score: Int, categoryId: String) {
        guard var g = game else { return }
        g.enterScore(score, for: categoryId)
        if !g.isFinished {
            g.advanceToNextPlayer()
        }
        game = g  // triggers @Observable notification via setter
        save()
    }

    func editScore(_ score: Int, categoryId: String, playerIndex: Int) {
        guard var g = game, playerIndex < g.players.count else { return }
        g.players[playerIndex].scores[categoryId] = score
        game = g
        save()
    }

    func clearGame() {
        if let names = game?.players.map(\.name), !names.isEmpty {
            lastPlayerNames = names
            if let data = try? JSONEncoder().encode(names) {
                UserDefaults.standard.set(data, forKey: lastPlayersKey)
            }
        }
        game = nil
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(game) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let g = try? JSONDecoder().decode(Game.self, from: data) {
            game = g
        }
        if let data = UserDefaults.standard.data(forKey: lastPlayersKey),
           let names = try? JSONDecoder().decode([String].self, from: data) {
            lastPlayerNames = names
        }
    }
}
