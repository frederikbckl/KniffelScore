import SwiftUI

private struct HScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct GameView: View {
    let store: GameStore
    @Binding var screen: AppScreen

    @State private var selectedCategory: ScoreCategory?
    @State private var editingPlayerIndex: Int?
    @State private var playerHeaderOffset: CGFloat = 0

    private let rowHeight: CGFloat = 38
    private let headerHeight: CGFloat = 52
    private let labelWidth: CGFloat = 130
    private let minColumnWidth: CGFloat = 76

    private var game: Game { store.game! }

    var body: some View {
        VStack(spacing: 0) {
            turnHeader
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))

            Divider()

            GeometryReader { geo in
                let availWidth = geo.size.width - labelWidth - 0.5
                let colWidth = max(minColumnWidth, availWidth / CGFloat(game.players.count))

                VStack(spacing: 0) {
                    // Sticky player name header row
                    HStack(alignment: .center, spacing: 0) {
                        Color(.systemBackground)
                            .frame(width: labelWidth, height: headerHeight)

                        Rectangle()
                            .fill(Color(.separator))
                            .frame(width: 0.5, height: headerHeight)

                        ZStack(alignment: .leading) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(Array(game.players.enumerated()), id: \.1.id) { idx, _ in
                                    playerHeader(playerIndex: idx, width: colWidth)
                                }
                            }
                            .offset(x: playerHeaderOffset)
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .frame(height: headerHeight)

                    Divider()

                    // Vertically scrollable score rows
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 0) {
                            labelColumn
                                .frame(width: labelWidth)
                                .background(Color(.systemBackground))

                            Rectangle()
                                .fill(Color(.separator))
                                .frame(width: 0.5)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    ForEach(Array(game.players.enumerated()), id: \.1.id) { idx, _ in
                                        playerScoreColumn(playerIndex: idx, width: colWidth)
                                    }
                                }
                                .background(
                                    GeometryReader { scrollGeo in
                                        Color.clear.preference(
                                            key: HScrollOffsetKey.self,
                                            value: scrollGeo.frame(in: .named("hscroll")).minX
                                        )
                                    }
                                )
                            }
                            .coordinateSpace(name: "hscroll")
                        }
                        .padding(.bottom, 16)
                    }
                }
                .onPreferenceChange(HScrollOffsetKey.self) { value in
                    playerHeaderOffset = value
                }
            }
        }
        .sheet(item: $selectedCategory) { cat in
            ScoreEntrySheetView(
                category: cat,
                playerName: sheetPlayerName
            ) { score in
                if game.isFinished, let idx = editingPlayerIndex {
                    store.editScore(score, categoryId: cat.id, playerIndex: idx)
                } else {
                    store.enterScore(score, categoryId: cat.id)
                }
            }
        }
    }

    // MARK: - Helpers

    private var sheetPlayerName: String {
        if let idx = editingPlayerIndex, idx < game.players.count {
            return game.players[idx].name
        }
        return game.currentPlayer.name
    }

    // MARK: - Turn header

    private var turnHeader: some View {
        HStack {
            Button {
                screen = .start
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(.tertiaryLabel))
            }

            Spacer()

            if game.isFinished {
                Button {
                    screen = .result
                } label: {
                    Text("Spiel beenden")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            } else {
                VStack(spacing: 2) {
                    Text(game.currentPlayer.name)
                        .font(.headline)
                    Text("Runde \(game.currentRound) von 13")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Mirror of close button to keep title centred
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.clear)
        }
    }

    // MARK: - Label column

    private var labelColumn: some View {
        VStack(spacing: 0) {
            ForEach(ScoreCategories.all) { cat in
                labelCell(cat: cat)
            }
        }
    }

    private func labelCell(cat: ScoreCategory) -> some View {
        HStack(spacing: 0) {
            Text(cat.name)
                .font(.caption)
                .foregroundStyle(cat.kind == .calculated ? Color.secondary : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .padding(.horizontal, 8)
            Spacer(minLength: 0)
        }
        .frame(height: rowHeight)
        .background(cat.kind == .calculated
            ? Color(.tertiarySystemBackground)
            : Color(.systemBackground))
        .overlay(alignment: .bottom) {
            rowSeparator(for: cat)
        }
    }

    // MARK: - Player header (sticky, above vertical scroll)

    private func playerHeader(playerIndex: Int, width: CGFloat) -> some View {
        let player = game.players[playerIndex]
        let isCurrent = !game.isFinished && playerIndex == game.currentPlayerIndex

        return VStack(spacing: 2) {
            Text(player.name)
                .font(.caption.weight(isCurrent ? .bold : .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 4)
            if isCurrent {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(width: width, height: headerHeight)
        .background(isCurrent
            ? Color.accentColor.opacity(0.12)
            : Color(.secondarySystemBackground))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(.separator).opacity(0.5))
                .frame(width: 0.5)
        }
    }

    // MARK: - Player score column (score rows only, no header)

    private func playerScoreColumn(playerIndex: Int, width: CGFloat) -> some View {
        let player = game.players[playerIndex]

        return VStack(spacing: 0) {
            ForEach(ScoreCategories.all) { cat in
                scoreCellContent(cat: cat, player: player, playerIndex: playerIndex)
                    .frame(width: width, height: rowHeight)
                    .overlay(alignment: .bottom) {
                        rowSeparator(for: cat)
                    }
            }
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(.separator).opacity(0.5))
                .frame(width: 0.5)
        }
    }

    // MARK: - Score cells

    @ViewBuilder
    private func scoreCellContent(
        cat: ScoreCategory, player: Player, playerIndex: Int
    ) -> some View {
        if cat.kind == .calculated {
            calculatedCell(categoryId: cat.id, player: player)
        } else {
            let score = player.scores[cat.id]
            let canTap = game.isFinished ||
                (playerIndex == game.currentPlayerIndex && score == nil)

            if canTap {
                Button {
                    editingPlayerIndex = playerIndex
                    selectedCategory = cat
                } label: {
                    if let s = score {
                        scoredCellLabel(score: s, dimmed: game.isFinished)
                    } else {
                        plusCellLabel()
                    }
                }
                .buttonStyle(.plain)
            } else if let s = score {
                scoredCellLabel(score: s, dimmed: false)
            } else {
                emptyCell()
            }
        }
    }

    private func calculatedCell(categoryId: String, player: Player) -> some View {
        let value = ScoreCalculator.calculatedValue(categoryId: categoryId, for: player)
        return Text(value.map { "\($0)" } ?? "—")
            .font(.caption.weight(.medium))
            .foregroundStyle(Color.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.tertiarySystemBackground))
    }

    private func scoredCellLabel(score: Int, dimmed: Bool) -> some View {
        Text("\(score)")
            .font(.callout.weight(.semibold))
            .foregroundStyle(score == 0 ? Color(.tertiaryLabel) : Color.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(dimmed ? Color.accentColor.opacity(0.04) : Color(.systemBackground))
    }

    private func plusCellLabel() -> some View {
        Image(systemName: "plus.circle.fill")
            .font(.body)
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.accentColor.opacity(0.07))
    }

    private func emptyCell() -> some View {
        Color(.systemBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Row separator

    @ViewBuilder
    private func rowSeparator(for cat: ScoreCategory) -> some View {
        if cat.id == "calc_upper" || cat.id == "calc_total" {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1.5)
        } else {
            Rectangle()
                .fill(Color(.separator).opacity(0.4))
                .frame(height: 0.5)
        }
    }
}
