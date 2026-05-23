import Foundation

enum ScoreCategories {
    static let all: [ScoreCategory] = [
        // Upper section
        .init(id: "einser",          name: "Einser",        kind: .upperSection, faceValue: 1),
        .init(id: "zweier",          name: "Zweier",        kind: .upperSection, faceValue: 2),
        .init(id: "dreier",          name: "Dreier",        kind: .upperSection, faceValue: 3),
        .init(id: "vierer",          name: "Vierer",        kind: .upperSection, faceValue: 4),
        .init(id: "fuenfer",         name: "Fünfer",        kind: .upperSection, faceValue: 5),
        .init(id: "sechser",         name: "Sechser",       kind: .upperSection, faceValue: 6),
        // Upper calculated
        .init(id: "calc_subtotal",   name: "Zwischensumme", kind: .calculated),
        .init(id: "calc_bonus",      name: "Bonus (+35)",   kind: .calculated),
        .init(id: "calc_upper",      name: "Summe Oben",    kind: .calculated),
        // Lower section
        .init(id: "dreierpasch",     name: "Dreierpasch",   kind: .freeScore,  freeMin: 5, freeMax: 30),
        .init(id: "viererpasch",     name: "Viererpasch",   kind: .freeScore,  freeMin: 5, freeMax: 30),
        .init(id: "fullhouse",       name: "Full House",    kind: .fixedScore, fixedPoints: 25),
        .init(id: "kleine_strasse",  name: "Kleine Straße", kind: .fixedScore, fixedPoints: 30),
        .init(id: "grosse_strasse",  name: "Große Straße",  kind: .fixedScore, fixedPoints: 40),
        .init(id: "kniffel",         name: "Kniffel",       kind: .fixedScore, fixedPoints: 50),
        .init(id: "chance",          name: "Chance",        kind: .freeScore,  freeMin: 5, freeMax: 30),
        // Lower calculated
        .init(id: "calc_lower",      name: "Summe Unten",   kind: .calculated),
        .init(id: "calc_upper_copy", name: "Summe Oben",    kind: .calculated),
        .init(id: "calc_total",      name: "Gesamtsumme",   kind: .calculated),
    ]

    static let scoreable: [ScoreCategory] = all.filter { $0.kind != .calculated }
}
