import SwiftUI

/// Utility for loading colors from the asset catalog with cross-platform fallbacks.
///
/// Usage examples:
///   Color(asset: "PrimaryColor")
///   AppColors.primary
///
struct AppColors {
    static let darkBlue = Color(asset: "DarkBlueColor")
    static let secondary = Color(asset: "SecondaryColor")
    static let accent = Color(asset: "AccentColor")
    static let danger = Color(asset: "DangerColor")
    static let darkGreen = Color(asset: "DarkGreenColor")
    static let lightBlue = Color(asset: "LightBlueColor")
    static let orange = Color(asset: "OrangeColor")
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
