import SwiftUI

struct ScoreEntrySheetView: View {
    let category: ScoreCategory
    let playerName: String
    let onSave: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var freeValue: Int = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text(category.name)
                        .font(.title.weight(.bold))
                    Text(playerName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 28)

                inputArea

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            freeValue = category.freeMin ?? 5
        }
    }

    // MARK: - Input routing

    @ViewBuilder
    private var inputArea: some View {
        switch category.kind {
        case .upperSection: upperSectionInput
        case .fixedScore:   fixedScoreInput
        case .freeScore:    freeScoreInput
        case .calculated:   EmptyView()
        }
    }

    // MARK: - Upper section (0× – 5×)

    private var upperSectionInput: some View {
        VStack(spacing: 20) {
            Text("Wie viele \(category.name) wurden gewürfelt?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                spacing: 10
            ) {
                ForEach(0...5, id: \.self) { count in
                    let points = count * (category.faceValue ?? 0)
                    Button {
                        commit(points)
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(count)×")
                                .font(.title2.weight(.bold))
                            Text("\(points) Pkt.")
                                .font(.caption)
                                .foregroundStyle(count == 0
                                    ? Color(.tertiaryLabel)
                                    : Color.appPrimary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(count == 0
                            ? Color(.tertiarySystemBackground)
                            : Color.appPrimary.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(count == 0
                                    ? Color.clear
                                    : Color.appPrimary.opacity(0.25),
                                    lineWidth: 1)
                        )
                    }
                    .foregroundStyle(count == 0 ? Color(.secondaryLabel) : Color.appPrimary)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Fixed score (Erfüllt / Gestrichen)

    private var fixedScoreInput: some View {
        VStack(spacing: 14) {
            if let pts = category.fixedPoints {
                Text("\(pts) Punkte bei Erfüllung")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Button {
                    commit(category.fixedPoints ?? 0)
                } label: {
                    Text("Erfüllt")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(Color.appPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    commit(0)
                } label: {
                    Text("Gestrichen")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(Color(.secondaryLabel))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Free score (wheel picker)

    private var freeScoreInput: some View {
        VStack(spacing: 20) {
            Picker("Punkte", selection: $freeValue) {
                ForEach((category.freeMin ?? 5)...(category.freeMax ?? 30), id: \.self) { v in
                    Text("\(v) Punkte").tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)

            VStack(spacing: 12) {
                Button {
                    commit(freeValue)
                } label: {
                    Text("Speichern — \(freeValue) Punkte")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.appPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    commit(0)
                } label: {
                    Text("Gestrichen (0 Punkte)")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(Color(.secondaryLabel))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Helpers

    private func commit(_ score: Int) {
        onSave(score)
        dismiss()
    }
}
