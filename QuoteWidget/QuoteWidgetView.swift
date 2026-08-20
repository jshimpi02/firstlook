import SwiftUI
import WidgetKit

/// Lock screen widgets are rendered by the system in flat, translucent
/// monochrome tinted to the user's accent color — no custom background or
/// text colors are honored here. `.widgetAccentable()` is the only styling
/// hook; everything else (fills, custom `Color`s) is intentionally omitted.
struct QuoteWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.quote.tag.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .widgetAccentable()
                .lineLimit(1)

            Text(entry.quote.text)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .containerBackground(for: .widget) { }
    }
}
