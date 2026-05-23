import SwiftUI

struct StartView: View {
    let store: GameStore
    @Binding var screen: AppScreen

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Kniffel")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("Spielstand")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 14) {
                Button {
                    screen = .playerSetup
                } label: {
                    Text("Neues Spiel")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if store.hasSavedGame {
                    Button {
                        screen = .game
                    } label: {
                        Text("Spiel fortsetzen")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(.secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }
}
