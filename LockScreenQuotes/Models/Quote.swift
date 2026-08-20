import Foundation

/// Hard limit enforced on `text` so every quote fits the accessoryRectangular
/// lock screen widget on one line, with no truncation or ellipsis.
let quoteCharacterBudget = 48

struct GeneralQuote: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let category: String
    let source: String?
}

struct GitaQuote: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let chapter: Int
    let verse: Int
    let category: String
}

struct QuoteBank: Codable {
    let general: [GeneralQuote]
    let gita: [GitaQuote]
}

/// A single quote normalized to what the widget actually needs to render:
/// a display tag (category, or "Gita · chapter.verse") and the quote text.
struct DisplayQuote: Identifiable, Hashable {
    let id: String
    let text: String
    let tag: String
}

extension GeneralQuote {
    var displayQuote: DisplayQuote {
        DisplayQuote(id: id, text: text, tag: category.capitalized)
    }
}

extension GitaQuote {
    var displayQuote: DisplayQuote {
        DisplayQuote(id: id, text: text, tag: "Gita · \(chapter).\(verse)")
    }
}
