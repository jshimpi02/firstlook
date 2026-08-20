import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: DisplayQuote
}

struct QuoteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: DisplayQuote(id: "placeholder", text: "Discipline equals freedom.", tag: "Discipline"))
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let settings = currentSettings()
        let quote = QuoteStore.shared.buildDailyPool(
            gitaMode: settings.gitaMode,
            mixSources: settings.mixSources,
            enabledCategories: settings.enabledCategories,
            entryCount: 1,
            seed: daySeed(for: Date())
        ).first ?? placeholder(in: context).quote
        completion(QuoteEntry(date: Date(), quote: quote))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        completion(Timeline(entries: buildTodayEntries(), policy: .after(nextMidnight())))
    }

    // MARK: - Dense daily schedule
    //
    // WidgetKit has no "screen woke up" event to hook into — timelines are
    // just a list of (date, entry) pairs the system renders whichever one
    // is current at refresh time, and the OS decides its own refresh budget
    // based on battery/usage. There's no way to force a refresh exactly when
    // the user looks at their lock screen.
    //
    // The practical workaround: pre-generate one entry every 20-30 minutes
    // across the hours someone is actually likely to glance at their phone
    // (6am-11pm), so whichever refresh the system happens to run, a fresh
    // quote is already queued up for "now". This reads as "changes pretty
    // much every time I check" without a literal on-wake hook, and keeps
    // the entry count modest (roughly 34-51/day) instead of blowing through
    // WidgetKit's daily timeline budget.
    private let wakingStartHour = 6
    private let wakingEndHour = 23
    private let minIntervalMinutes = 20
    private let maxIntervalMinutes = 30

    private func buildTodayEntries() -> [QuoteEntry] {
        let calendar = Calendar.current
        let now = Date()
        guard let dayStart = calendar.date(
            bySettingHour: wakingStartHour, minute: 0, second: 0, of: now
        ), let dayEnd = calendar.date(
            bySettingHour: wakingEndHour, minute: 0, second: 0, of: now
        ) else {
            let fallback = DisplayQuote(id: "fallback", text: "Discipline equals freedom.", tag: "Discipline")
            return [QuoteEntry(date: now, quote: fallback)]
        }

        let settings = currentSettings()
        let seed = daySeed(for: now)

        var slotDates: [Date] = []
        var cursor = dayStart
        var stepSeed = seed
        while cursor < dayEnd {
            slotDates.append(cursor)
            var stepGenerator = SeededGenerator(seed: stepSeed)
            let minutes = Int.random(in: minIntervalMinutes...maxIntervalMinutes, using: &stepGenerator)
            cursor = calendar.date(byAdding: .minute, value: minutes, to: cursor) ?? dayEnd
            stepSeed += 1
        }
        // Guarantee at least one entry covering the moment the timeline is built.
        if slotDates.isEmpty || slotDates.first! > now {
            slotDates.insert(dayStart, at: 0)
        }

        let quotes = QuoteStore.shared.buildDailyPool(
            gitaMode: settings.gitaMode,
            mixSources: settings.mixSources,
            enabledCategories: settings.enabledCategories,
            entryCount: slotDates.count,
            seed: seed
        )

        return zip(slotDates, quotes).map { QuoteEntry(date: $0, quote: $1) }
    }

    private func nextMidnight() -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return calendar.startOfDay(for: tomorrow)
    }

    /// Stable per-day seed so the schedule (slot count/spacing and quote
    /// selection) only changes once per calendar day, not on every rebuild.
    private func daySeed(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return (components.year ?? 0) * 10_000 + (components.month ?? 0) * 100 + (components.day ?? 0)
    }

    private func currentSettings() -> (gitaMode: Bool, mixSources: Bool, enabledCategories: Set<String>) {
        (AppGroupDefaults.gitaMode, AppGroupDefaults.mixSources, AppGroupDefaults.enabledCategories)
    }
}
