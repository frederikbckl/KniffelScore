import SwiftUI

struct ResultView: View {
    let store: GameStore
    @Binding var screen: AppScreen

    private struct RankedPlayer: Identifiable {
        var id: UUID { player.id }
        let player: Player
        let total: Int
        let rank: Int
    }

    private var ranked: [RankedPlayer] {
        guard let game = store.game else { return [] }
        let sorted = game.players
            .map { ($0, ScoreCalculator.grandTotal(for: $0)) }
            .sorted { $0.1 > $1.1 }

        var result: [RankedPlayer] = []
        for (i, item) in sorted.enumerated() {
            let rank: Int
            if i == 0 {
                rank = 1
            } else if item.1 == sorted[i - 1].1 {
                rank = result[i - 1].rank
            } else {
                rank = i + 1
            }
            result.append(RankedPlayer(player: item.0, total: item.1, rank: rank))
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            if let winner = ranked.first {
                VStack(spacing: 6) {
                    Text("GEWINNER")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .tracking(1.5)
                    Text(winner.player.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("\(winner.total) Punkte")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(Color.accentColor.opacity(0.1))
            }

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(ranked) { item in
                        HStack(spacing: 12) {
                            Text("\(item.rank).")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(item.rank == 1 ? Color.accentColor : Color(.tertiaryLabel))
                                .frame(width: 32, alignment: .leading)

                            Text(item.player.name)
                                .font(.title3.weight(item.rank == 1 ? .semibold : .regular))

                            Spacer()

                            Text("\(item.total) Pkt.")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(item.rank == 1 ? Color.accentColor : .primary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(item.rank == 1 ? Color.accentColor.opacity(0.05) : Color(.systemBackground))

                        Divider().padding(.leading, 24)
                    }
                }
                .padding(.top, 8)
            }

            Spacer(minLength: 0)

            Button {
                store.clearGame()
                screen = .start
            } label: {
                Text("Neues Spiel")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
}
