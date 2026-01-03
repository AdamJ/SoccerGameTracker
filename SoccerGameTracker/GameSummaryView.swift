import SwiftUI

struct GameSummaryView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // TODO: Update Game Info Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Game Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(game.location)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(game.gameDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // TODO: Update Score Section
                HStack {
                    Text("Final Score:")
                        .font(.headline)
                    Spacer()
                    Text("\(game.ourScore) - \(game.opponentScore)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Player Stats Section
                if !game.playerStats.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player Statistics")
                            .font(.headline)
                        
                        ForEach(game.playerStats.filter { $0.goals > 0 || $0.assists > 0 || $0.saves > 0 || $0.totalShots > 0 }, id: \.id) { stats in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stats.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("G:\(stats.goals) S:\(stats.totalShots) A:\(stats.assists)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("#\(stats.number)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }

                // Action Log Section
                if !game.actions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game Actions")
                            .font(.headline)
                            .padding(.horizontal)

                        let firstHalfActions = game.actions
                            .filter { $0.gameHalf == .first }
                            .sorted { $0.elapsedSeconds < $1.elapsedSeconds }

                        let secondHalfActions = game.actions
                            .filter { $0.gameHalf == .second }
                            .sorted { $0.elapsedSeconds < $1.elapsedSeconds }

                        if !firstHalfActions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Half")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(SemanticColors.primary)
                                    .padding(.horizontal)

                                ForEach(firstHalfActions) { action in
                                    ActionSummaryRow(action: action)
                                }
                            }
                        }

                        if !secondHalfActions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Second Half")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(SemanticColors.primary)
                                    .padding(.horizontal)

                                ForEach(secondHalfActions) { action in
                                    ActionSummaryRow(action: action)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Game Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func generateCSV() -> String {
        var csvString = "Name,Number,Position,Goals,Shots,Assists,Saves\n"

        for stats in game.playerStats {
            csvString += "\(stats.name),\(stats.number),\(stats.position.rawValue),\(stats.goals),\(stats.totalShots),\(stats.assists),\(stats.saves)\n"
        }

        return csvString
    }
}

struct ActionSummaryRow: View {
    let action: GameAction

    var body: some View {
        HStack(spacing: 12) {
            // Time
            Text(action.timeString())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(SemanticColors.textSecondary)
                .frame(width: 40, alignment: .leading)

            // Icon
            Image(systemName: action.actionType.icon)
                .font(.caption)
                .foregroundColor(action.actionType.color)
                .frame(width: 20)

            // Description
            Text(action.displayDescription())
                .font(.caption)
                .foregroundColor(SemanticColors.textPrimary)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct GameSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameSummaryView(game: PreviewManagers(populated: true).gameManager.currentGame!)
        }
    }
}
#endif
