import SwiftUI

struct EndGameConfirmationView: View {
    let game: Game
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false

    private var gameSummaryText: String {
        var summary = "⚽️ Game Summary\n\n"
        summary += "📅 Date: \(game.gameDate.formatted(date: .abbreviated, time: .omitted))\n"
        summary += "📍 Location: \(game.location)\n"
        summary += "🆚 Opponent: \(game.opponentName)\n\n"
        summary += "Final Score: \(game.ourScore) - \(game.opponentScore)\n"
        summary += game.ourScore > game.opponentScore ? "✅ Win\n\n" : game.ourScore < game.opponentScore ? "❌ Loss\n\n" : "🤝 Draw\n\n"

        // Player stats
        let playersWithStats = game.playerStats.filter {
            $0.goals > 0 || $0.assists > 0 || $0.saves > 0 || $0.totalShots > 0
        }

        if !playersWithStats.isEmpty {
            summary += "👥 Player Stats:\n"
            for stats in playersWithStats.sorted(by: { $0.number < $1.number }) {
                summary += "#\(stats.number) \(stats.name)"
                var statParts: [String] = []
                if stats.goals > 0 { statParts.append("\(stats.goals)G") }
                if stats.assists > 0 { statParts.append("\(stats.assists)A") }
                if stats.saves > 0 { statParts.append("\(stats.saves)SV") }
                if stats.totalShots > 0 { statParts.append("\(stats.totalShots)SH") }
                if !statParts.isEmpty {
                    summary += " - " + statParts.joined(separator: ", ")
                }
                summary += "\n"
            }
        }

        return summary
    }

    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.xxl) {
                Spacer()

                // Icon
                Image(systemName: "flag.checkered")
                    .font(.system(size: 70))
                    .foregroundColor(SemanticColors.primary)

                // Title
                Text("End Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Final Score Display
                ScoreDisplay(
                    homeScore: game.ourScore,
                    opponentScore: game.opponentScore,
                    opponentName: game.opponentName
                )
                .padding()
                .cardStyle(backgroundColor: SemanticColors.surfaceVariant)

                Text("Share the game summary or finish")
                    .font(.body)
                    .foregroundColor(SemanticColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Action Buttons
                VStack(spacing: DesignTokens.Spacing.md) {
                    Button {
                        showingShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share & End Game")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: SemanticColors.primary))

                    Button {
                        // End game without sharing
                        dismiss()
                        onComplete()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("End Game")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(SecondaryButtonStyle(
                        borderColor: SemanticColors.primary,
                        foregroundColor: SemanticColors.primary
                    ))
                }
                .padding(.horizontal)
                .padding(.bottom, DesignTokens.Spacing.xxl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingShareSheet, onDismiss: {
                // After share sheet is dismissed, complete the game ending process
                dismiss()
                onComplete()
            }) {
                ShareSheet(items: [gameSummaryText])
            }
        }
    }
}

#if DEBUG
struct EndGameConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let managers = PreviewManagers(populated: true)
        let game = Game(
            opponentName: "Rivals",
            gameDate: Date(),
            location: "Home Field",
            roster: managers.rosterManager.roster,
            durationInSeconds: 25 * 60
        )
        game.ourScore = 3
        game.opponentScore = 2

        return EndGameConfirmationView(
            game: game,
            onComplete: {}
        )
    }
}
#endif
