import SwiftUI

struct GameSetupView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var rosterManager: RosterManager
    @EnvironmentObject var gameHistoryManager: GameHistoryManager
    
    @State private var opponentName: String = ""
    @State private var gameDate = Date()
    @State private var location: String = ""
    @State private var halfDurationMinutes: Int = 45
    @State private var selectedPlayers: Set<UUID> = []
    @State private var showingGameTracker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let halfDurationOptions = [20, 25, 30, 35, 40, 45, 50]
    
    var body: some View {
        NavigationView {
            if gameManager.isGameActive {
                gameActiveView
            } else {
                gameSetupForm
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showingGameTracker) {
            if let game = gameManager.currentGame {
                NavigationView {
                    GameTrackerView(game: game)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("End Game") {
                                    gameManager.endGame()
                                    showingGameTracker = false
                                }
                                .foregroundColor(AppColors.danger)
                            }
                        }
                }
            }
        }
    }
    
    private var gameActiveView: some View {
        VStack(spacing: 20) {
            Image(systemName: "soccer.ball")
                .font(.system(size: 80))
                .foregroundColor(AppColors.primary)
            
            Text("Game in Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primary)
            
            if let game = gameManager.currentGame {
                VStack(spacing: 8) {
                    Text("vs \(game.opponentName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("at \(game.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(game.gameDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Button("Continue Game") {
                showingGameTracker = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            .font(.headline)
            
            Button("End Current Game") {
                gameManager.endGame()
            }
            .buttonStyle(.bordered)
            .foregroundColor(AppColors.danger)
        }
        .padding()
        .navigationTitle("Current Game")
    }
    
    private var gameSetupForm: some View {
        Form {
            Section("Game Details") {
                TextField("Opponent Name", text: $opponentName)
                    .textInputAutocapitalization(.words)
                
                DatePicker("Game Date", selection: $gameDate, displayedComponents: [.date, .hourAndMinute])
                
                TextField("Location", text: $location)
                    .textInputAutocapitalization(.words)
                
                Picker("Half Duration", selection: $halfDurationMinutes) {
                    ForEach(halfDurationOptions, id: \.self) { duration in
                        Text("\(duration) minutes")
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section {
                if rosterManager.roster.isEmpty {
                    Text("No players in roster. Add players in the Roster tab first.")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(rosterManager.roster) { player in
                        PlayerSelectionRow(
                            player: player,
                            isSelected: selectedPlayers.contains(player.id)
                        ) {
                            togglePlayerSelection(player.id)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Select Players (\(selectedPlayers.count)/\(rosterManager.roster.count))")
                    Spacer()
                    if !rosterManager.roster.isEmpty {
                        Button(selectedPlayers.count == rosterManager.roster.count ? "Deselect All" : "Select All") {
                            if selectedPlayers.count == rosterManager.roster.count {
                                selectedPlayers.removeAll()
                            } else {
                                selectedPlayers = Set(rosterManager.roster.map { $0.id })
                            }
                        }
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                    }
                }
            }
            
            Section {
                Button("Start Game") {
                    startGame()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .disabled(!canStartGame)
            }
        }
        .navigationTitle("New Game")
        .onAppear {
            // Pre-select all players by default
            selectedPlayers = Set(rosterManager.roster.map { $0.id })
        }
    }
    
    private var canStartGame: Bool {
        !opponentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedPlayers.isEmpty
    }
    
    private func togglePlayerSelection(_ playerId: UUID) {
        if selectedPlayers.contains(playerId) {
            selectedPlayers.remove(playerId)
        } else {
            selectedPlayers.insert(playerId)
        }
    }
    
    private func startGame() {
        let trimmedOpponent = opponentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOpponent.isEmpty else {
            alertMessage = "Please enter an opponent name."
            showingAlert = true
            return
        }
        
        guard !trimmedLocation.isEmpty else {
            alertMessage = "Please enter a location."
            showingAlert = true
            return
        }
        
        guard !selectedPlayers.isEmpty else {
            alertMessage = "Please select at least one player."
            showingAlert = true
            return
        }
        
        let selectedRoster = rosterManager.roster.filter { selectedPlayers.contains($0.id) }
        let halfDurationInSeconds = halfDurationMinutes * 60
        
        gameManager.startGame(
            opponentName: trimmedOpponent,
            gameDate: gameDate,
            location: trimmedLocation,
            roster: selectedRoster,
            durationInSeconds: halfDurationInSeconds
        )
        
        showingGameTracker = true
    }
}

struct PlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTap) {
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? AppColors.primary : .secondary)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .fontWeight(.medium)
                        Text("#\(player.number) • \(player.position.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
