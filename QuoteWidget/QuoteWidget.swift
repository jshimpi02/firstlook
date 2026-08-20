import SwiftUI
import WidgetKit

struct QuoteWidget: Widget {
    let kind = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteTimelineProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Quote")
        .description("A short motivational or Gita quote for your lock screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}

@main
struct QuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteWidget()
    }
}
