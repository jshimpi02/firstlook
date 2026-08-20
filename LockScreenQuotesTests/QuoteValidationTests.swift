import XCTest
@testable import LockScreenQuotes

final class QuoteValidationTests: XCTestCase {
    private func loadBank() throws -> QuoteBank {
        let bundle = Bundle(for: Self.self)
        let url = try XCTUnwrap(bundle.url(forResource: "Quotes", withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(QuoteBank.self, from: data)
    }

    func testNoQuoteExceedsCharacterBudget() throws {
        let bank = try loadBank()

        for quote in bank.general {
            XCTAssertLessThanOrEqual(
                quote.text.count, quoteCharacterBudget,
                "general/\(quote.id) is \(quote.text.count) chars: \"\(quote.text)\""
            )
        }
        for quote in bank.gita {
            XCTAssertLessThanOrEqual(
                quote.text.count, quoteCharacterBudget,
                "gita/\(quote.id) is \(quote.text.count) chars: \"\(quote.text)\""
            )
        }
    }

    func testEveryGitaChapterHasCoverage() throws {
        let bank = try loadBank()
        let chapters = Set(bank.gita.map(\.chapter))
        for chapter in 1...18 {
            XCTAssertTrue(chapters.contains(chapter), "No Gita quote found for chapter \(chapter)")
        }
    }

    func testNoDuplicateIDs() throws {
        let bank = try loadBank()
        let generalIDs = bank.general.map(\.id)
        let gitaIDs = bank.gita.map(\.id)
        XCTAssertEqual(generalIDs.count, Set(generalIDs).count, "Duplicate general quote id found")
        XCTAssertEqual(gitaIDs.count, Set(gitaIDs).count, "Duplicate gita quote id found")
    }
}
