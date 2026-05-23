import SwiftUI

struct StartView: View {
    let store: GameStore
    @Binding var screen: AppScreen

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
                        Image(systemName: "die.face.5.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.appPrimary)
                    }

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
}
