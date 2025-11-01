import SwiftUI

/// Utility for loading colors from the asset catalog with cross-platform fallbacks.
///
/// Usage examples:
///   Color(asset: "PrimaryColor")
///   AppColors.primary
///
struct AppColors {
    static let darkBlue = Color(asset: "AppDarkBlueColor")
    static let blue = Color(asset: "AppSecondaryColor")
    static let accent = Color(asset: "AccentColor")
    static let danger = Color(asset: "AppDangerColor")
    static let darkGreen = Color(asset: "AppDarkGreenColor")
    /// 'primary' uses the same color as 'darkGreen'. Change if a different primary is desired.
    static let primary = Color(asset: "AppDarkGreenColor")
    static let coral = Color(asset: "AppCoralColor")
    static let orange = Color(asset: "AppOrangeColor")
    static let onAccent = Color("AppCoralColor").opacity(0.5)
    static let fieldBackground = Color("FieldBackgroundColor")
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
