import Foundation

enum ScoreCalculator {
    static func upperSubtotal(for player: Player) -> Int {
        ScoreCategories.all
            .filter { $0.kind == .upperSection }
            .compactMap { player.scores[$0.id] }
            .reduce(0, +)
    }

    static func bonus(for player: Player) -> Int {
        upperSubtotal(for: player) >= 63 ? 35 : 0
    }

    static func upperTotal(for player: Player) -> Int {
        upperSubtotal(for: player) + bonus(for: player)
    }

    static func lowerSubtotal(for player: Player) -> Int {
        ScoreCategories.all
            .filter { $0.kind == .fixedScore || $0.kind == .freeScore }
            .compactMap { player.scores[$0.id] }
            .reduce(0, +)
    }

    static func grandTotal(for player: Player) -> Int {
        upperTotal(for: player) + lowerSubtotal(for: player)
    }

    static func calculatedValue(categoryId: String, for player: Player) -> Int? {
        let upperCats = ScoreCategories.all.filter { $0.kind == .upperSection }
        let lowerCats = ScoreCategories.all.filter { $0.kind == .fixedScore || $0.kind == .freeScore }
        let upperFilled = upperCats.filter { player.scores[$0.id] != nil }.count
        let lowerFilled = lowerCats.filter { player.scores[$0.id] != nil }.count

        switch categoryId {
        case "calc_subtotal":
            return upperFilled > 0 ? upperSubtotal(for: player) : nil

        case "calc_bonus":
            // Show 35 as soon as it's earned; show 0 only when all 6 are filled without earning it;
            // show — while still in progress
            let subtotal = upperSubtotal(for: player)
            if subtotal >= 63 { return 35 }
            return upperFilled == upperCats.count ? 0 : nil

        case "calc_upper":
            return upperFilled > 0 ? upperTotal(for: player) : nil

        case "calc_lower":
            return lowerFilled > 0 ? lowerSubtotal(for: player) : nil

        case "calc_upper_copy":
            return upperFilled > 0 ? upperTotal(for: player) : nil

        case "calc_total":
            return (upperFilled + lowerFilled) > 0 ? grandTotal(for: player) : nil

        default:
            return nil
        }
    }
}
