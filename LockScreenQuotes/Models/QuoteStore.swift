import Foundation

/// Loads the bundled quote bank and applies the user's current settings
/// (Gita mode, mix sources, category filters) to produce the pool of quotes
/// the widget is allowed to show right now.
final class QuoteStore {
    static let shared = QuoteStore()

    private let bank: QuoteBank

    private init() {
        bank = Self.loadBundledBank()
        assert(Self.validateCharacterBudget(bank), "Quotes.json contains a quote longer than \(quoteCharacterBudget) characters")
    }

    private static func loadBundledBank() -> QuoteBank {
        guard let url = Bundle.main.url(forResource: "Quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(QuoteBank.self, from: data) else {
            return QuoteBank(general: [], gita: [])
        }
        return decoded
    }

    /// Debug-only guardrail: fails loudly at launch if any bundled quote
    /// exceeds the one-line character budget, instead of clipping silently
    /// on-device.
    private static func validateCharacterBudget(_ bank: QuoteBank) -> Bool {
        bank.general.allSatisfy { $0.text.count <= quoteCharacterBudget }
            && bank.gita.allSatisfy { $0.text.count <= quoteCharacterBudget }
    }

    var generalQuotes: [GeneralQuote] { bank.general }
    var gitaQuotes: [GitaQuote] { bank.gita }

    /// Quotes matching the currently-enabled general categories. Falls back
    /// to the full general bank if no category is enabled, so the widget
    /// never has an empty pool.
    func filteredGeneralQuotes(enabledCategories: Set<String>) -> [GeneralQuote] {
        let matches = bank.general.filter { enabledCategories.contains($0.category) }
        return matches.isEmpty ? bank.general : matches
    }

    /// Builds the ordered pool of display quotes for one day, honoring
    /// Gita mode, the mix ratio, and category filters.
    func buildDailyPool(
        gitaMode: Bool,
        mixSources: Bool,
        enabledCategories: Set<String>,
        entryCount: Int,
        seed: Int
    ) -> [DisplayQuote] {
        var generator = SeededGenerator(seed: seed)

        guard gitaMode else {
            let pool = filteredGeneralQuotes(enabledCategories: enabledCategories)
            return (0..<entryCount).map { _ in
                pool.randomElement(using: &generator)!.displayQuote
            }
        }

        guard mixSources, !bank.general.isEmpty else {
            return (0..<entryCount).map { _ in
                bank.gita.randomElement(using: &generator)!.displayQuote
            }
        }

        // 1 general quote per `gitaMixRatio` Gita quotes, interleaved.
        let ratio = AppGroupDefaults.gitaMixRatio
        return (0..<entryCount).map { index in
            if index % (ratio + 1) == ratio {
                return bank.general.randomElement(using: &generator)!.displayQuote
            }
            return bank.gita.randomElement(using: &generator)!.displayQuote
        }
    }
}

/// Deterministic RNG so a given day's timeline is reproducible (same seed
/// -> same sequence), rather than re-randomizing on every timeline rebuild.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        state = UInt64(bitPattern: Int64(seed)) &+ 0x9E3779B97F4A7C15
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
