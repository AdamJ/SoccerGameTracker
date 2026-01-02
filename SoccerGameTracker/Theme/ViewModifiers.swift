import SwiftUI

// MARK: - Card Style Modifier
struct CardStyle: ViewModifier {
    var backgroundColor: Color = SemanticColors.surface
    var cornerRadius: CGFloat = DesignTokens.CornerRadius.lg
    var shadowEnabled: Bool = false

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .if(shadowEnabled) { view in
                view.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = SemanticColors.primary
    var foregroundColor: Color = .white
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isEnabled ? foregroundColor : SemanticColors.textTertiary)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(isEnabled ? backgroundColor : SemanticColors.surfaceVariant)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    var borderColor: Color = SemanticColors.primary
    var foregroundColor: Color = SemanticColors.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(borderColor, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Badge Style Modifier
struct BadgeStyle: ViewModifier {
    var color: Color
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
            case .medium:
                return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large:
                return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }

        var fontSize: Font {
            switch self {
            case .small:
                return .caption2
            case .medium:
                return .caption
            case .large:
                return .body
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .font(size.fontSize)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(size.padding)
            .background(color.opacity(DesignTokens.Opacity.overlay))
            .cornerRadius(DesignTokens.CornerRadius.sm)
    }
}

// MARK: - Section Header Style
struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(SemanticColors.primary)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.sm)
    }
}

// MARK: - Divider Style
struct ThickDividerStyle: ViewModifier {
    var color: Color = SemanticColors.surfaceVariant
    var height: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .background(color)
    }
}

// MARK: - Conditional View Modifier
extension View {
    /// Applies a transformation if condition is true
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies different transformations based on condition
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}

// MARK: - View Extensions for Modifiers
extension View {
    func cardStyle(
        backgroundColor: Color = SemanticColors.surface,
        cornerRadius: CGFloat = DesignTokens.CornerRadius.lg,
        shadowEnabled: Bool = false
    ) -> some View {
        modifier(CardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowEnabled: shadowEnabled
        ))
    }

    func badgeStyle(color: Color, size: BadgeStyle.BadgeSize = .medium) -> some View {
        modifier(BadgeStyle(color: color, size: size))
    }

    func sectionHeader() -> some View {
        modifier(SectionHeaderStyle())
    }

    func thickDivider(color: Color = SemanticColors.surfaceVariant, height: CGFloat = 1) -> some View {
        modifier(ThickDividerStyle(color: color, height: height))
    }
}
