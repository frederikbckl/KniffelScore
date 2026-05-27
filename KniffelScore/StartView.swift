import SwiftUI

struct StartView: View {
    let store: GameStore
    @Binding var screen: AppScreen

    @State private var diceValue = 5
    @State private var flipAngle: Double = 0
    @State private var isRolling = false

    var body: some View {
        ZStack {
            // Very subtle purple wash at the top
            LinearGradient(
                colors: [Color.appPrimary.opacity(0.07), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero emblem + title
                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.10))
                            .frame(width: 104, height: 104)
                        Circle()
                            .strokeBorder(Color.appPrimary.opacity(0.20), lineWidth: 1)
                            .frame(width: 104, height: 104)
                        Image(systemName: "die.face.\(diceValue).fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.appPrimary)
                            .rotation3DEffect(
                                .degrees(flipAngle),
                                axis: (x: 0, y: 1, z: 0)
                            )
                    }
                    .onTapGesture { rollDice() }

                    VStack(spacing: 6) {
                        Text("Kniffel")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appPrimary)
                        Text(" ") // enter subtitle if necessary
                            .font(.title3.weight(.regular))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        screen = .playerSetup
                    } label: {
                        Text("Neues Spiel")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.appPrimary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if store.hasSavedGame {
                        Button {
                            screen = .game
                        } label: {
                            Text("Spiel fortsetzen")
                                .font(.title2.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.appPrimary.opacity(0.10))
                                .foregroundStyle(Color.appPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }

    private func rollDice() {
        guard !isRolling else { return }
        isRolling = true
        // Phase 1: spin current face to edge-on (invisible at 90°)
        withAnimation(.easeIn(duration: 0.13)) {
            flipAngle = 90
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.13))
            // Swap the face while the die is edge-on, then jump to the mirror angle
            diceValue = Int.random(in: 1...6)
            flipAngle = -90
            // Phase 2: new face rotates in from the edge
            withAnimation(.easeOut(duration: 0.13)) {
                flipAngle = 0
            }
            try? await Task.sleep(for: .seconds(0.13))
            isRolling = false
        }
    }
}
