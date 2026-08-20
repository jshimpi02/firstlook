import Foundation

/// Thin wrapper around the shared `UserDefaults(suiteName:)` that the main
/// app and the widget extension both read/write. This is the only channel
/// they have for talking to each other — they run in separate processes.
enum AppGroupDefaults {
    static let suiteName = "group.com.firstlook.lockscreenquotes"

    private enum Key {
        static let gitaMode = "gitaMode"
        static let mixSources = "mixSources"
        static let enabledCategories = "enabledCategories"
    }

    static let allGeneralCategories = ["discipline", "focus", "resilience", "stoic", "gratitude"]

    /// How many Gita quotes appear, on average, per interleaved general quote
    /// when Gita mode + mix sources are both on (1 general per 4 Gita).
    static let gitaMixRatio = 4

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static var gitaMode: Bool {
        get { defaults.object(forKey: Key.gitaMode) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Key.gitaMode) }
    }

    static var mixSources: Bool {
        get { defaults.object(forKey: Key.mixSources) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Key.mixSources) }
    }

    /// Which `general` categories are active. First launch defaults to all on.
    static var enabledCategories: Set<String> {
        get {
            guard let stored = defaults.array(forKey: Key.enabledCategories) as? [String] else {
                return Set(allGeneralCategories)
            }
            return Set(stored)
        }
        set { defaults.set(Array(newValue), forKey: Key.enabledCategories) }
    }
}
