import SwiftUI
import WidgetKit

struct SettingsView: View {
    @State private var gitaMode = AppGroupDefaults.gitaMode
    @State private var mixSources = AppGroupDefaults.mixSources
    @State private var enabledCategories = AppGroupDefaults.enabledCategories

    private let allCategories = AppGroupDefaults.allGeneralCategories

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Bhagavad Gita mode", isOn: $gitaMode)
                        .onChange(of: gitaMode) { _, newValue in
                            AppGroupDefaults.gitaMode = newValue
                            reloadWidget()
                        }
                } footer: {
                    Text("On: the widget pulls only from Gita verses. Off: it pulls from your general quote categories below.")
                }

                if gitaMode {
                    Section {
                        Toggle("Mix in general quotes", isOn: $mixSources)
                            .onChange(of: mixSources) { _, newValue in
                                AppGroupDefaults.mixSources = newValue
                                reloadWidget()
                            }
                    } footer: {
                        Text("Occasionally interleaves a general quote — roughly 1 in every \(AppGroupDefaults.gitaMixRatio + 1) shown.")
                    }
                }

                if !gitaMode {
                    Section {
                        chipGrid
                    } header: {
                        Text("Categories")
                    } footer: {
                        Text("Choose which categories the widget can draw from. At least one stays selected.")
                    }
                }
            }
            .navigationTitle("Lock Screen Quotes")
        }
    }

    private var chipGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(allCategories, id: \.self) { category in
                let isOn = enabledCategories.contains(category)
                Button {
                    toggleCategory(category)
                } label: {
                    Text(category.capitalized)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isOn ? Color.accentColor : Color.secondary.opacity(0.15))
                        .foregroundStyle(isOn ? Color.white : Color.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private func toggleCategory(_ category: String) {
        var updated = enabledCategories
        if updated.contains(category) {
            // Never let the last enabled category be removed.
            guard updated.count > 1 else { return }
            updated.remove(category)
        } else {
            updated.insert(category)
        }
        enabledCategories = updated
        AppGroupDefaults.enabledCategories = updated
        reloadWidget()
    }

    private func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Simple wrapping chip layout — categories don't fit a fixed grid width.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: width, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    SettingsView()
}
