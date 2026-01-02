import SwiftUI

/// Legacy color utility - bridged to semantic colors for backward compatibility
/// New code should use SemanticColors directly
struct AppColors {
    // Primary colors mapped to semantic system
    static let primary = SemanticColors.primary
    static let darkGreen = SemanticColors.success

    // Secondary colors
    static let darkBlue = SemanticColors.secondary
    static let blue = SemanticColors.info

    // Status colors
    static let danger = SemanticColors.error
    static let orange = SemanticColors.warning

    // Accent colors
    static let accent = SemanticColors.accent
    static let coral = SemanticColors.accentVariant
    static let onAccent = SemanticColors.accent.opacity(0.5)

    // Surface colors
    static let fieldBackground = SemanticColors.surfaceVariant
}

extension Color {
    /// Initialize a SwiftUI Color from an asset catalog color name.
    /// This supports iOS/tvOS/watchOS (UIColor) and macOS (NSColor) and falls back to a clear color when not found.
    init(asset name: String, bundle: Bundle = .main) {
        #if os(iOS) || os(tvOS) || os(watchOS)
        if let uiColor = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self = Color(uiColor)
        } else {
            self = Color.clear
        }
        #elseif os(macOS)
        if let nsColor = NSColor(named: NSColor.Name(name), bundle: bundle) {
            self = Color(nsColor)
        } else {
            self = Color.clear
        }
        #else
        self = Color.clear
        #endif
    }
}
