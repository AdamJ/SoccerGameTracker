import SwiftUI
import UniformTypeIdentifiers

struct GameHistoryView: View {
    @EnvironmentObject var gameHistoryManager: GameHistoryManager
    @State private var showingExportAlert = false
    @State private var showingShareSheet = false
    @State private var csvData = ""
    @State private var selectedGame: Game?
    
    var body: some View {
        NavigationView {
            if gameHistoryManager.completedGames.isEmpty {
                emptyStateView
            } else {
                gameHistoryList
            }
        }
        .sheet(item: $selectedGame) { game in
            GameDetailView(game: game)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [csvData])
        }
        .alert("Export Complete", isPresented: $showingExportAlert) {
            Button("Share CSV") {
                showingShareSheet = true
            }
            Button("OK") { }
        } message: {
            Text("Game history has been exported to CSV format.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary.opacity(0.6))
            
            Text("No Game History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete games will appear here automatically. Start your first game in the New Game tab!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Game History")
    }
    
    private var gameHistoryList: some View {
        List {
            Section {
                ForEach(gameHistoryManager.completedGames) { game in
                    GameHistoryRowView(game: game) {
                        selectedGame = game
                    }
                }
                .onDelete(perform: deleteGame)
            } header: {
                HStack {
                    Text("\(gameHistoryManager.completedGames.count) Games")
                    Spacer()
                    Text("Tap for details")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Game History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Export CSV") {
                    exportToCSV()
                }
                .foregroundColor(AppColors.primary)
            }
        }
    }
    
    private func deleteGame(offsets: IndexSet) {
        gameHistoryManager.deleteGames(at: offsets)
    }
    
    private func exportToCSV() {
        csvData = generateCSV()
        showingExportAlert = true
    }
    
    private func generateCSV() -> String {
        var csv = "Date,Opponent,Location,Result,Our Score,Opponent Score,Player Name,Player Number,Position,Goals,Assists,Yellow Cards,Red Cards,Saves,Shots,Substituted\n"
        
        for game in gameHistoryManager.completedGames {
            let dateString = DateFormatter.csvDate.string(from: game.gameDate)
            let result = game.ourScore > game.opponentScore ? "W" : game.ourScore < game.opponentScore ? "L" : "T"
            
            for player in game.playerStats {
                csv += "\"\(dateString)\",\"\(game.opponentName)\",\"\(game.location)\",\"\(result)\",\(game.ourScore),\(game.opponentScore),\"\(player.name)\",\(player.number),\"\(player.position.displayName)\",\(player.goals),\(player.assists),\(player.yellowCards),\(player.redCards),\(player.saves),\(player.totalShots),\(player.isSubstituted)\n"
            }
            
            // Add a row for unknown goals if any
            if game.unknownGoals > 0 {
                csv += "\"\(dateString)\",\"\(game.opponentName)\",\"\(game.location)\",\"\(result)\",\(game.ourScore),\(game.opponentScore),\"Unknown Player\",0,\"Unknown\",\(game.unknownGoals),0,0,0,0,0,false\n"
            }
        }
        
        return csv
    }
}

struct GameHistoryRowView: View {
    let game: Game
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Game header
                    HStack {
                        Text("vs \(game.opponentName)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(gameResultText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(gameResultColor)
                            .cornerRadius(16)
                    }
                    
                    // Score
                    Text("Score: \(game.ourScore) - \(game.opponentScore)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                    
                    // Game details
                    HStack {
                        Label(game.location, systemImage: "location")
                        Spacer()
                        Label(DateFormatter.shortDate.string(from: game.gameDate), systemImage: "calendar")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    // Player stats summary
                    HStack(spacing: 16) {
                        if totalGoals > 0 {
                            Label("\(totalGoals)", systemImage: "soccerball")
                                .font(.caption)
                                .foregroundColor(AppColors.primary)
                        }
                        if totalAssists > 0 {
                            Label("\(totalAssists)", systemImage: "hand.thumbsup")
                                .font(.caption)
                                .foregroundColor(AppColors.darkBlue)
                        }
                        if totalCards > 0 {
                            Label("\(totalCards)", systemImage: "rectangle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private var gameResultText: String {
        if game.ourScore > game.opponentScore {
            return "W"
        } else if game.ourScore < game.opponentScore {
            return "L"
        } else {
            return "T"
        }
    }
    
    private var gameResultColor: Color {
        if game.ourScore > game.opponentScore {
            return AppColors.darkGreen
        } else if game.ourScore < game.opponentScore {
            return AppColors.danger
        } else {
            return AppColors.orange
        }
    }
    
    private var totalGoals: Int {
        game.playerStats.reduce(0) { $0 + $1.goals } + game.unknownGoals
    }
    
    private var totalAssists: Int {
        game.playerStats.reduce(0) { $0 + $1.assists }
    }
    
    private var totalCards: Int {
        game.playerStats.reduce(0) { $0 + $1.yellowCards + $1.redCards }
    }
}

struct GameDetailView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Game header
                    gameHeaderSection
                    
                    // Score section
                    scoreSection
                    
                    // Player stats section
                    playerStatsSection
                }
                .padding()
            }
            .navigationTitle("Game Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var gameHeaderSection: some View {
        VStack(spacing: 8) {
            Text("vs \(game.opponentName)")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                Label(game.location, systemImage: "location")
                Label(DateFormatter.fullDate.string(from: game.gameDate), systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var scoreSection: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("HOME")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text("\(game.ourScore)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
            }
            
            Text(":")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text(game.opponentName.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text("\(game.opponentScore)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.coral)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var playerStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Player Statistics")
                .font(.headline)
                .foregroundColor(AppColors.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(game.playerStats.sorted(by: { $0.number < $1.number })) { player in
                    PlayerDetailRow(player: player)
                }
                
                if game.unknownGoals > 0 {
                    UnknownGoalsRow(goals: game.unknownGoals)
                }
            }
        }
    }
}

struct PlayerDetailRow: View {
    let player: PlayerStats
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Player info
                VStack(spacing: 2) {
                    Text("#\(player.number)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                    Text(player.position.abbreviation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.body)
                        .fontWeight(.medium)
                    if player.isSubstituted {
                        Text("SUBSTITUTED")
                            .font(.caption2)
                            .foregroundColor(AppColors.orange)
                    }
                }
                
                Spacer()
            }
            
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                if player.goals > 0 {
                    StatDisplayItem(label: "Goals", value: player.goals, icon: "soccerball", color: AppColors.primary)
                }
                if player.assists > 0 {
                    StatDisplayItem(label: "Assists", value: player.assists, icon: "hand.thumbsup", color: AppColors.darkBlue)
                }
                if player.yellowCards > 0 {
                    StatDisplayItem(label: "Yellow", value: player.yellowCards, icon: "rectangle", color: .yellow)
                }
                if player.redCards > 0 {
                    StatDisplayItem(label: "Red", value: player.redCards, icon: "rectangle.fill", color: AppColors.danger)
                }
                if player.saves > 0 {
                    StatDisplayItem(label: "Saves", value: player.saves, icon: "hand.raised", color: AppColors.darkGreen)
                }
                if player.totalShots > 0 {
                    StatDisplayItem(label: "Shots", value: player.totalShots, icon: "target", color: AppColors.darkBlue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct StatDisplayItem: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UnknownGoalsRow: View {
    let goals: Int
    
    var body: some View {
        HStack {
            Image(systemName: "questionmark.circle")
                .font(.title2)
                .foregroundColor(AppColors.orange)
            
            VStack(alignment: .leading) {
                Text("Unknown Player")
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(goals) goal\(goals == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let csvDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
}
