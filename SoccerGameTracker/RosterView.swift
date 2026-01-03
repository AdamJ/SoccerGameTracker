import SwiftUI

struct RosterView: View {
    @EnvironmentObject var rosterManager: RosterManager
    @State private var showingAddPlayer = false

    // Group players by position
    private var groupedPlayers: [(Position, [Player])] {
        let positions: [Position] = [.goalkeeper, .defender, .midfielder, .forward]
        var grouped: [(Position, [Player])] = []

        for position in positions {
            let players = rosterManager.roster
                .filter { $0.position == position }
                .sorted { $0.number < $1.number }
            if !players.isEmpty {
                grouped.append((position, players))
            }
        }

        return grouped
    }

    private var substitutes: [Player] {
        rosterManager.roster
            .filter { $0.position == .substitute }
            .sorted { $0.number < $1.number }
    }

    var body: some View {
        NavigationView {
            List {
                // Team configuration section
                Section {
                    // Team name field
                    HStack {
                        Text("Team Name")
                            .foregroundColor(SemanticColors.textSecondary)
                        TextField("Enter team name", text: $rosterManager.homeTeamName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(SemanticColors.textPrimary)
                    }

                    // Team format picker
                    Picker("Team Format", selection: $rosterManager.teamFormat) {
                        ForEach(TeamFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(SemanticColors.info)
                        Text(rosterManager.teamFormat.description)
                            .font(.caption)
                            .foregroundColor(SemanticColors.textSecondary)
                    }

                    // Home/Away toggle
                    Picker("Team Status", selection: $rosterManager.isHomeTeam) {
                        Text("Home").tag(true)
                        Text("Away").tag(false)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Team Configuration")
                }

                // Players grouped by position
                ForEach(groupedPlayers, id: \.0) { position, players in
                    Section {
                        ForEach(players) { player in
                            PlayerRowView(player: player)
                        }
                        .onDelete { offsets in
                            deletePlayersFromSection(players: players, offsets: offsets)
                        }
                    } header: {
                        HStack {
                            Text(position.displayName)
                            Spacer()
                            Text("\(players.count)")
                                .foregroundColor(SemanticColors.textSecondary)
                        }
                    }
                }

                // Substitutes section (separate from other positions)
                if !substitutes.isEmpty {
                    Section {
                        ForEach(substitutes) { player in
                            PlayerRowView(player: player)
                        }
                        .onDelete { offsets in
                            deletePlayersFromSection(players: substitutes, offsets: offsets)
                        }
                    } header: {
                        HStack {
                            Text("Substitutes")
                            Spacer()
                            Text("\(substitutes.count)")
                                .foregroundColor(SemanticColors.textSecondary)
                        }
                    }
                }

                // Empty state
                if rosterManager.roster.isEmpty {
                    Section {
                        VStack(spacing: DesignTokens.Spacing.md) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: DesignTokens.IconSize.lg))
                                .foregroundColor(SemanticColors.textTertiary)

                            Text("No Players")
                                .font(.headline)
                                .foregroundColor(SemanticColors.textSecondary)

                            Text("Tap the + button to add players to your roster")
                                .font(.caption)
                                .foregroundColor(SemanticColors.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.xl)
                    }
                }
            }
            .navigationTitle("Roster")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(SemanticColors.primary)
                    }
                    .accessibilityLabel("Add Player")
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView(rosterManager: rosterManager)
            }
        }
    }

    private func deletePlayersFromSection(players: [Player], offsets: IndexSet) {
        let playersToDelete = offsets.map { players[$0] }
        for player in playersToDelete {
            if let index = rosterManager.roster.firstIndex(where: { $0.id == player.id }) {
                rosterManager.roster.remove(at: index)
            }
        }
    }
}

struct PlayerRowView: View {
    let player: Player

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Player number badge
            PlayerNumberBadge(number: player.number, position: player.position.abbreviation)

            // Player info
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(SemanticColors.textPrimary)

                Text(player.position.displayName)
                    .font(.caption)
                    .foregroundColor(SemanticColors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
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
