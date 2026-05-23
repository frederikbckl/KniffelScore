import SwiftUI

enum AppScreen {
    case start, playerSetup, game, result
}

struct ContentView: View {
    @State private var store = GameStore()
    @State private var screen: AppScreen = .start

    var body: some View {
        Group {
            switch screen {
            case .start:
                StartView(store: store, screen: $screen)
            case .playerSetup:
                PlayerSetupView(store: store, screen: $screen)
            case .game:
                if store.game != nil {
                    GameView(store: store, screen: $screen)
                } else {
                    StartView(store: store, screen: $screen)
                        .onAppear { screen = .start }
                }
            case .result:
                if store.game != nil {
                    ResultView(store: store, screen: $screen)
                } else {
                    StartView(store: store, screen: $screen)
                        .onAppear { screen = .start }
                }
            }
        }
        .tint(Color.appPrimary)
    }
}
