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
        ZStack(alignment: .top) {
            VStack(spacing: 0) {

            // ── Winner banner ──────────────────────────────────────────────
            if let winner = ranked.first {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.appPrimary,
                            Color(red: 88/255, green: 28/255, blue: 135/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 10) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.white.opacity(0.85))

                        Text("GEWINNER")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.65))
                            .tracking(2.5)

                        Text(winner.player.name)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("\(winner.total) Punkte")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.appGreen)
                    }
                    .padding(.vertical, 44)
                }
                .frame(maxWidth: .infinity)
            }

            // ── Ranking list ───────────────────────────────────────────────
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(ranked) { item in
                        HStack(spacing: 14) {
                            // Circular rank badge
                            ZStack {
                                Circle()
                                    .fill(item.rank == 1
                                        ? Color.appPrimary
                                        : Color(.tertiarySystemBackground))
                                    .frame(width: 36, height: 36)
                                Text("\(item.rank)")
                                    .font(.callout.weight(.bold))
                                    .foregroundStyle(item.rank == 1
                                        ? .white
                                        : Color(.tertiaryLabel))
                            }

                            Text(item.player.name)
                                .font(.body.weight(item.rank == 1 ? .semibold : .regular))

                            Spacer()

                            Text("\(item.total) Pkt.")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(item.rank == 1
                                    ? Color.appPrimary
                                    : Color(.secondaryLabel))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)

                        Divider()
                            .padding(.leading, 74) // align with name text
                    }
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)

            // ── Buttons ────────────────────────────────────────────────────
            VStack(spacing: 12) {
                Button {
                    store.clearGame()
                    screen = .playerSetup
                } label: {
                    Text("Nochmal!")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.appPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    store.clearGame()
                    screen = .start
                } label: {
                    Text("Tschau Kakao")
                        .font(.body.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(Color(.secondaryLabel))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        } // VStack

        // Confetti fires once when the screen appears, then stops
        ConfettiView()

        } // ZStack
    }
}
