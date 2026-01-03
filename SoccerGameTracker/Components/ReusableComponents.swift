import SwiftUI

// MARK: - Score Display Component
struct ScoreDisplay: View {
    let ourScore: Int
    let opponentScore: Int
    let ourTeamName: String
    let opponentName: String
    let isHomeTeam: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xl) {
            // Left side (our team if home, opponent if away)
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(isHomeTeam ? ourTeamName.uppercased() : opponentName.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(SemanticColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text("\(isHomeTeam ? ourScore : opponentScore)")
                    .font(.system(size: DesignTokens.FontSize.display, weight: .bold, design: .rounded))
                    .foregroundColor(isHomeTeam ? SemanticColors.primary : SemanticColors.accentVariant)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(isHomeTeam ? ourTeamName : opponentName) score: \(isHomeTeam ? ourScore : opponentScore)")

            Text(":")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(SemanticColors.textSecondary)
                .accessibilityHidden(true)

            // Right side (opponent if home, our team if away)
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(isHomeTeam ? opponentName.uppercased() : ourTeamName.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(SemanticColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text("\(isHomeTeam ? opponentScore : ourScore)")
                    .font(.system(size: DesignTokens.FontSize.display, weight: .bold, design: .rounded))
                    .foregroundColor(isHomeTeam ? SemanticColors.accentVariant : SemanticColors.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(isHomeTeam ? opponentName : ourTeamName) score: \(isHomeTeam ? opponentScore : ourScore)")
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
    }
}

// MARK: - Game Status Badge
struct GameStatusBadge: View {
    let status: String
    var color: Color = SemanticColors.primary

    var body: some View {
        Text(status)
            .font(.headline)
            .fontWeight(.semibold)
            .badgeStyle(color: color, size: .medium)
    }
}

// MARK: - Timer Display Component
struct TimerDisplay: View {
    let timeString: String
    let isRunning: Bool

    var body: some View {
        Text(timeString)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
            .foregroundColor(isRunning ? SemanticColors.primary : SemanticColors.textSecondary)
            .accessibilityLabel("Time remaining: \(timeString)")
            .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var iconColor: Color = SemanticColors.warning

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: DesignTokens.IconSize.xl))
                .foregroundColor(iconColor)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(SemanticColors.textPrimary)

            Text(message)
                .font(.body)
                .foregroundColor(SemanticColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle(
            backgroundColor: color,
            foregroundColor: .white,
            isEnabled: !isDisabled
        ))
        .disabled(isDisabled)
    }
}

// MARK: - Stat Badge Component (Reusable)
struct StatBadgeView: View {
    let icon: String
    let value: Int
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(DesignTokens.Opacity.overlay))
        .cornerRadius(DesignTokens.CornerRadius.sm)
        .accessibilityLabel("\(value) \(label)")
    }
}

// MARK: - Player Number Badge
struct PlayerNumberBadge: View {
    let number: Int
    let position: String

    var body: some View {
        VStack(spacing: 2) {
            Text("#\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(SemanticColors.primary)
            Text(position)
                .font(.caption2)
                .foregroundColor(SemanticColors.textSecondary)
        }
        .frame(width: 40)
    }
}
