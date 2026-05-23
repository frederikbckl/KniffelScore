import SwiftUI

private struct PlayerEntry: Identifiable {
    let id = UUID()
    var name: String
}

struct PlayerSetupView: View {
    let store: GameStore
    @Binding var screen: AppScreen

    @State private var entries: [PlayerEntry]

    init(store: GameStore, screen: Binding<AppScreen>) {
        self.store = store
        self._screen = screen
        let previous = store.lastPlayerNames
        if previous.isEmpty {
            _entries = State(initialValue: [
                PlayerEntry(name: "Spieler:in 1"),
                PlayerEntry(name: "Spieler:in 2"),
            ])
        } else {
            _entries = State(initialValue: previous.map { PlayerEntry(name: $0) })
        }
    }

    private var canStart: Bool {
        !entries.isEmpty &&
        entries.allSatisfy { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section("Spieler:in") {
                        ForEach($entries) { $entry in
                            TextField("Name", text: $entry.name)
                        }
                        .onDelete { entries.remove(atOffsets: $0) }

                        if entries.count < 10 {
                            Button {
                                entries.append(PlayerEntry(name: "Spieler:in \(entries.count + 1)"))
                            } label: {
                                Label("Spieler:in hinzufügen", systemImage: "plus")
                            }
                        }
                    }
                }

                Button {
                    let names = entries.map { $0.name.trimmingCharacters(in: .whitespaces) }
                    store.startNewGame(playerNames: names)
                    screen = .game
                } label: {
                    Text("Spiel starten")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(canStart ? Color.appPrimary : Color(.systemGray3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canStart)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationTitle("Spieler:in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") { screen = .start }
                }
            }
        }
    }
}
