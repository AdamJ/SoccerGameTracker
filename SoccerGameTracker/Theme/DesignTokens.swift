import SwiftUI

/// Design tokens for consistent spacing, sizing, and typography throughout the app
enum DesignTokens {
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let pill: CGFloat = 999
    }

    // MARK: - Font Sizes
    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let headline: CGFloat = 18
        static let title: CGFloat = 24
        static let largeTitle: CGFloat = 34
        static let display: CGFloat = 48
    }

    // MARK: - Icon Sizes
    enum IconSize {
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 48
    }

    // MARK: - Opacity
    enum Opacity {
        static let disabled: Double = 0.38
        static let inactive: Double = 0.60
        static let pressed: Double = 0.12
        static let hover: Double = 0.08
        static let overlay: Double = 0.15
    }

    // MARK: - Animation
    enum Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}
