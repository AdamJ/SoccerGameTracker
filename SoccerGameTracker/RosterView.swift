import SwiftUI

struct RosterView: View {
    @EnvironmentObject var rosterManager: RosterManager
    @EnvironmentObject var gameManager: GameManager
    @State private var showingAddPlayer = false
    @State private var playerToEdit: Player?
    @State private var showingGKDeletionAlert = false

    // Group players by position (starting lineup only, excludes substitutes)
    private var groupedPlayers: [(Position, [Player])] {
        let positions: [Position] = [.goalkeeper, .defender, .midfielder, .forward]
        var grouped: [(Position, [Player])] = []

        for position in positions {
            let players = rosterManager.roster
                .filter { $0.position == position && !$0.isSubstitute }
                .sorted { $0.number < $1.number }
            if !players.isEmpty {
                grouped.append((position, players))
            }
        }

        return grouped
    }

    private var substitutes: [Player] {
        rosterManager.roster
            .filter { $0.isSubstitute }
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
                                .onTapGesture {
                                    if !gameManager.isGameActive {
                                        playerToEdit = player
                                    }
                                }
                                .opacity(gameManager.isGameActive ? 0.5 : 1.0)
                        }
                        .onDelete { offsets in
                            if !gameManager.isGameActive {
                                let playersToDelete = offsets.map { players[$0] }
                                if rosterManager.wouldRemoveOnlyGoalkeeper(removing: playersToDelete) {
                                    showingGKDeletionAlert = true
                                } else {
                                    deletePlayersFromSection(players: players, offsets: offsets)
                                }
                            }
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
                            PlayerRowView(player: player, showSubstituteLabel: true)
                                .onTapGesture {
                                    if !gameManager.isGameActive {
                                        playerToEdit = player
                                    }
                                }
                                .opacity(gameManager.isGameActive ? 0.5 : 1.0)
                        }
                        .onDelete { offsets in
                            if !gameManager.isGameActive {
                                deletePlayersFromSection(players: substitutes, offsets: offsets)
                            }
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
                    .disabled(gameManager.isGameActive)
                    .opacity(gameManager.isGameActive ? 0.5 : 1.0)
                    .accessibilityLabel("Add Player")
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView(rosterManager: rosterManager)
            }
            .sheet(item: $playerToEdit) { player in
                PlayerEditView(
                    rosterManager: rosterManager,
                    player: Binding(
                        get: { player },
                        set: { _ in }
                    )
                )
            }
            .alert("Cannot Delete Goalkeeper", isPresented: $showingGKDeletionAlert) {
                Button("OK") {}
            } message: {
                Text("Your team must have at least one goalkeeper in the starting lineup.")
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
    var showSubstituteLabel: Bool = false

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Player number badge
            PlayerNumberBadge(number: player.number, position: player.position.abbreviation)

            // Player info
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(SemanticColors.textPrimary)

                // Show position with SUB indicator if needed
                if showSubstituteLabel {
                    Text("\(player.position.displayName) • SUB")
                        .font(.caption)
                        .foregroundColor(SemanticColors.textSecondary)
                } else {
                    Text(player.position.displayName)
                        .font(.caption)
                        .foregroundColor(SemanticColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }
}

#if DEBUG
struct RosterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Empty roster
            RosterView()
                .environmentObject(RosterManager())
                .environmentObject(GameManager())
                .previewDisplayName("Empty Roster")

            // Populated roster with starters and substitutes
            RosterView()
                .environmentObject(populatedRosterManager())
                .environmentObject(GameManager())
                .previewDisplayName("Populated Roster")
        }
    }

    static func populatedRosterManager() -> RosterManager {
        let manager = RosterManager()
        manager.homeTeamName = "Hawks FC"
        manager.teamFormat = .sevenVSeven
        manager.isHomeTeam = true

        // Starting lineup (7 players for 7v7)
        manager.roster = [
            Player(name: "Emma Johnson", number: 1, position: .goalkeeper, isSubstitute: false),
            Player(name: "Sophia Martinez", number: 3, position: .defender, isSubstitute: false),
            Player(name: "Olivia Davis", number: 5, position: .defender, isSubstitute: false),
            Player(name: "Ava Wilson", number: 7, position: .midfielder, isSubstitute: false),
            Player(name: "Isabella Brown", number: 8, position: .midfielder, isSubstitute: false),
            Player(name: "Mia Garcia", number: 10, position: .forward, isSubstitute: false),
            Player(name: "Charlotte Rodriguez", number: 11, position: .forward, isSubstitute: false),

            // Substitutes (retain their positions)
            Player(name: "Amelia Lee", number: 2, position: .goalkeeper, isSubstitute: true),
            Player(name: "Harper Taylor", number: 4, position: .defender, isSubstitute: true),
            Player(name: "Evelyn Anderson", number: 9, position: .midfielder, isSubstitute: true),
            Player(name: "Abigail Thomas", number: 12, position: .forward, isSubstitute: true)
        ]

        return manager
    }
}
#endif
