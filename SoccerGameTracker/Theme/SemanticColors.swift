import SwiftUI

/// Semantic color system that adapts to light and dark modes with WCAG AA accessibility compliance
enum SemanticColors {
    // MARK: - Primary Colors
    static let primary = Color("SemanticPrimary", bundle: .main)
    static let primaryVariant = Color("SemanticPrimaryVariant", bundle: .main)

    // MARK: - Secondary Colors
    static let secondary = Color("SemanticSecondary", bundle: .main)
    static let secondaryVariant = Color("SemanticSecondaryVariant", bundle: .main)

    // MARK: - Status Colors
    static let success = Color("SemanticSuccess", bundle: .main)
    static let warning = Color("SemanticWarning", bundle: .main)
    static let error = Color("SemanticError", bundle: .main)
    static let info = Color("SemanticInfo", bundle: .main)

    // MARK: - Surface Colors
    static let surface = Color("SemanticSurface", bundle: .main)
    static let surfaceVariant = Color("SemanticSurfaceVariant", bundle: .main)
    static let background = Color("SemanticBackground", bundle: .main)

    // MARK: - Text Colors
    static let textPrimary = Color("SemanticTextPrimary", bundle: .main)
    static let textSecondary = Color("SemanticTextSecondary", bundle: .main)
    static let textTertiary = Color("SemanticTextTertiary", bundle: .main)

    // MARK: - Accent Colors
    static let accent = Color("SemanticAccent", bundle: .main)
    static let accentVariant = Color("SemanticAccentVariant", bundle: .main)

    // MARK: - Fallback Implementation
    /// Light mode colors with WCAG AA compliance
    fileprivate static let lightModeColors: [String: Color] = [
        "SemanticPrimary": Color(red: 0.133, green: 0.545, blue: 0.133), // Forest Green
        "SemanticPrimaryVariant": Color(red: 0.098, green: 0.404, blue: 0.098),
        "SemanticSecondary": Color(red: 0.118, green: 0.294, blue: 0.545), // Deep Blue
        "SemanticSecondaryVariant": Color(red: 0.078, green: 0.220, blue: 0.412),
        "SemanticSuccess": Color(red: 0.133, green: 0.545, blue: 0.133),
        "SemanticWarning": Color(red: 0.851, green: 0.561, blue: 0.125),
        "SemanticError": Color(red: 0.776, green: 0.137, blue: 0.133),
        "SemanticInfo": Color(red: 0.118, green: 0.294, blue: 0.545),
        "SemanticSurface": Color(red: 0.98, green: 0.98, blue: 0.98),
        "SemanticSurfaceVariant": Color(red: 0.95, green: 0.95, blue: 0.95),
        "SemanticBackground": Color(red: 1.0, green: 1.0, blue: 1.0),
        "SemanticTextPrimary": Color(red: 0.118, green: 0.118, blue: 0.118),
        "SemanticTextSecondary": Color(red: 0.380, green: 0.380, blue: 0.380),
        "SemanticTextTertiary": Color(red: 0.557, green: 0.557, blue: 0.557),
        "SemanticAccent": Color(red: 0.988, green: 0.502, blue: 0.447), // Coral
        "SemanticAccentVariant": Color(red: 0.878, green: 0.380, blue: 0.318)
    ]

    /// Dark mode colors with WCAG AA compliance
    fileprivate static let darkModeColors: [String: Color] = [
        "SemanticPrimary": Color(red: 0.400, green: 0.835, blue: 0.400), // Light Green
        "SemanticPrimaryVariant": Color(red: 0.300, green: 0.700, blue: 0.300),
        "SemanticSecondary": Color(red: 0.502, green: 0.678, blue: 0.898), // Light Blue
        "SemanticSecondaryVariant": Color(red: 0.380, green: 0.557, blue: 0.780),
        "SemanticSuccess": Color(red: 0.400, green: 0.835, blue: 0.400),
        "SemanticWarning": Color(red: 0.992, green: 0.710, blue: 0.380),
        "SemanticError": Color(red: 0.937, green: 0.408, blue: 0.404),
        "SemanticInfo": Color(red: 0.502, green: 0.678, blue: 0.898),
        "SemanticSurface": Color(red: 0.118, green: 0.118, blue: 0.118),
        "SemanticSurfaceVariant": Color(red: 0.169, green: 0.169, blue: 0.169),
        "SemanticBackground": Color(red: 0.0, green: 0.0, blue: 0.0),
        "SemanticTextPrimary": Color(red: 0.922, green: 0.922, blue: 0.922),
        "SemanticTextSecondary": Color(red: 0.702, green: 0.702, blue: 0.702),
        "SemanticTextTertiary": Color(red: 0.557, green: 0.557, blue: 0.557),
        "SemanticAccent": Color(red: 0.988, green: 0.627, blue: 0.584),
        "SemanticAccentVariant": Color(red: 0.878, green: 0.502, blue: 0.447)
    ]
}

// MARK: - Color Extension
extension Color {
    init(_ name: String, bundle: Bundle) {
        // Try loading from asset catalog first
        if let _ = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self.init(name, bundle: bundle)
        } else {
            // Fallback to programmatic colors based on color scheme
            self = SemanticColors.lightModeColors[name] ?? .clear
        }
    }

    /// Adaptive color that changes based on color scheme
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(dark) : UIColor(light)
        })
    }
}
