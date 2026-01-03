import SwiftUI

struct ActionsTabView: View {
    @ObservedObject var game: Game

    // Computed properties to group actions by half
    private var firstHalfActions: [GameAction] {
        game.actions
            .filter { $0.gameHalf == .first }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var secondHalfActions: [GameAction] {
        game.actions
            .filter { $0.gameHalf == .second }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                if game.actions.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet.clipboard",
                        title: "No Actions Yet",
                        message: "Actions like goals, assists, saves, and cards will appear here as they happen"
                    )
                    .padding(.top, DesignTokens.Spacing.xxl)
                } else {
                    // Show second half first if it exists
                    if !secondHalfActions.isEmpty {
                        actionSection(title: "Second Half", actions: secondHalfActions)
                    }

                    if !firstHalfActions.isEmpty {
                        actionSection(title: "First Half", actions: firstHalfActions)
                    }
                }
            }
            .padding(.vertical, DesignTokens.Spacing.md)
        }
    }

    @ViewBuilder
    private func actionSection(title: String, actions: [GameAction]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(SemanticColors.primary)
                .padding(.horizontal)

            VStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(actions) { action in
                    ActionRow(action: action) {
                        withAnimation {
                            game.removeAction(action)
                        }
                    }
                }
            }
        }
    }
}

struct ActionRow: View {
    let action: GameAction
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            Image(systemName: action.actionType.icon)
                .font(.title3)
                .foregroundColor(action.actionType.color)
                .frame(width: 32)

            // Action details
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(action.displayDescription())
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(SemanticColors.textPrimary)

                // Metadata row
                HStack(spacing: DesignTokens.Spacing.sm) {
                    // Game time
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(action.timeString())
                            .font(.caption)
                    }
                    .foregroundColor(SemanticColors.textSecondary)

                    if let number = action.playerNumber {
                        Text("• #\(number)")
                            .font(.caption)
                            .foregroundColor(SemanticColors.textSecondary)
                    }

                    // Actual timestamp
                    Text("• \(action.timestamp, format: .dateTime.hour().minute())")
                        .font(.caption)
                        .foregroundColor(SemanticColors.textTertiary)
                }
            }

            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .cardStyle(backgroundColor: SemanticColors.surfaceVariant)
        .padding(.horizontal)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#if DEBUG
struct ActionsTabView_Previews: PreviewProvider {
    static var previews: some View {
        let managers = PreviewManagers(populated: true)
        let game = managers.gameManager.currentGame!

        // Add some sample actions
        game.logAction(
            actionType: .teamGoal,
            playerId: game.playerStats[0].id,
            playerName: game.playerStats[0].name,
            playerNumber: game.playerStats[0].number
        )

        game.logAction(
            actionType: .teamGoalWithAssist,
            playerId: game.playerStats[1].id,
            playerName: game.playerStats[1].name,
            playerNumber: game.playerStats[1].number,
            assistPlayerId: game.playerStats[2].id,
            assistPlayerName: game.playerStats[2].name,
            assistPlayerNumber: game.playerStats[2].number
        )

        game.logAction(
            actionType: .save,
            playerId: game.playerStats[0].id,
            playerName: game.playerStats[0].name,
            playerNumber: game.playerStats[0].number
        )

        game.logAction(
            actionType: .yellowCard,
            playerId: game.playerStats[3].id,
            playerName: game.playerStats[3].name,
            playerNumber: game.playerStats[3].number
        )

        game.logAction(
            actionType: .opponentGoal,
            playerName: game.opponentName
        )

        return NavigationView {
            ActionsTabView(game: game)
                .navigationTitle("Game Actions")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
