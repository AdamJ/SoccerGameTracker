import SwiftUI

struct RosterView: View {
    @EnvironmentObject var rosterManager: RosterManager
    @State private var showingAddPlayer = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(rosterManager.roster) { player in
                    PlayerRowView(player: player)
                }
                .onDelete(perform: deletePlayer)
            }
            .navigationTitle("Roster")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Player") {
                        showingAddPlayer = true
                    }
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView(rosterManager: rosterManager)
            }
        }
    }
    
    private func deletePlayer(offsets: IndexSet) {
        rosterManager.removePlayer(at: offsets)
    }
}

struct PlayerRowView: View {
    let player: Player
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.headline)
                Text("\(player.position.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            // MARK: - Add ability to edit player details
            Text("#\(player.number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
}

#if DEBUG
struct RosterView_Previews: PreviewProvider {
    static var previews: some View {
        RosterView()
            .environmentObject(RosterManager())
    }
}
#endif
