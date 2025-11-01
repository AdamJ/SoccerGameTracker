import SwiftUI

struct GameSummaryView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Game Info Section
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
                
                // Score Section
                HStack {
                    Text("Final Score:")
                        .font(.headline)
                    Spacer()
                    Text("\(game.ourScore) - \(game.opponentScore)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
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

#if DEBUG
struct GameSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameSummaryView(game: PreviewManagers(populated: true).gameManager.currentGame!)
        }
    }
}
#endif
