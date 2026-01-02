import SwiftUI

struct GameTrackerView: View {
    @ObservedObject var game: Game
    @State private var selectedPlayerForStats: PlayerStats?
    @State private var showingPlayerStatsModal = false
    @State private var showingGameSummary = false
    @State private var showingHalfTimeAlert = false
    @State private var showingGoalAssignmentModal = false
    @State private var showingGoalRemovalModal = false
    @State private var showingOpponentGoalRemovalModal = false
    @State private var showingEndGameConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with score and game info
            gameHeader
            
            // Timer and game controls
            timerSection
            
            // Quick actions
            quickActionsSection
            
            // Players list
            playersSection
        }
        .navigationTitle("Live Game")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPlayerStatsModal) {
            if let player = selectedPlayerForStats {
                PlayerStatsDetailView(playerStats: player, game: game)
            }
        }
        .sheet(isPresented: $showingGameSummary) {
            GameSummaryView(game: game)
        }
        .sheet(isPresented: $showingGoalAssignmentModal) {
            GoalAssignmentView(game: game)
        }
        .sheet(isPresented: $showingGoalRemovalModal) {
            GoalRemovalView(game: game)
        }
        .sheet(isPresented: $showingOpponentGoalRemovalModal) {
            OpponentGoalRemovalView(game: game)
        }
        .sheet(isPresented: $showingEndGameConfirmation) {
            EndGameConfirmationView(
                ourScore: game.ourScore,
                opponentScore: game.opponentScore,
                onConfirm: {
                    showingEndGameConfirmation = false
                    showingGameSummary = true
                },
                onCancel: {
                    showingEndGameConfirmation = false
                    game.startTimer()
                }
            )
        }
        .alert("Half Time", isPresented: $showingHalfTimeAlert) {
            Button("Start Second Half") {
                game.startTimer()
            }
            Button("View Summary") {
                showingGameSummary = true
            }
        } message: {
            Text("First half completed. The second half is ready to start.")
        }
        .onChange(of: game.remainingSeconds) { newValue in
            if newValue == 0 && game.currentHalf == .first {
                showingHalfTimeAlert = true
            }
        }
    }
    
    private var gameHeader: some View {
        VStack(spacing: 8) {
            // Game info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(game.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(game.gameDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(game.currentHalf.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.1))
                    .foregroundColor(AppColors.primary)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Score display
            HStack(spacing: 20) {
                // Home team score
                VStack(spacing: 4) {
                    Text("HOME")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text("\(game.ourScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Home team score: \(game.ourScore)")
                
                Text(":")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                
                // Away team score
                VStack(spacing: 4) {
                    Text(game.opponentName.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("\(game.opponentScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.coral)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(game.opponentName) score: \(game.opponentScore)")
            }
            .padding(.vertical, 8)
        }
        .padding(.bottom, 16)
        .background(Color(.systemGray6))
    }
    
    private var timerSection: some View {
        VStack(spacing: 12) {
            // Timer display
            Text(game.timeString())
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(game.isTimerRunning ? AppColors.primary : .secondary)
                .accessibilityLabel("Time remaining: \(game.timeString())")
                .accessibilityAddTraits(.updatesFrequently)
            
            // Timer controls
            HStack(spacing: 12) {
                Button(game.isTimerRunning ? "Pause" : "Start") {
                    if game.isTimerRunning {
                        game.stopTimer()
                    } else {
                        game.startTimer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(game.isTimerRunning ? AppColors.orange : AppColors.primary)
                .font(.headline)
                .accessibilityLabel(game.isTimerRunning ? "Pause timer" : "Start timer")
                
                // End Half button - always available during first half
                if game.currentHalf == .first {
                    Button("End Half") {
                        game.stopTimer()
                        game.endHalf()
                        showingHalfTimeAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(AppColors.primary)
                    .accessibilityLabel("End first half")
                } else if game.currentHalf == .second {
                    // End Game button - available during second half
                    Button("End Game") {
                        game.stopTimer()
                        showingEndGameConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(AppColors.danger)
                    .accessibilityLabel("End game")
                }
                
                Button("Summary") {
                    showingGameSummary = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(AppColors.darkBlue)
                .accessibilityLabel("View game summary")
            }
        }
        .padding()
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(AppColors.primary)
            
            // First row - Our team actions
            HStack(spacing: 12) {
                // Our goal button - opens assignment modal
                Button {
                    showingGoalAssignmentModal = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "soccerball")
                            .font(.title2)
                        Text("Team Goal")
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                
                // Remove our goal button
                Button {
                    showingGoalRemovalModal = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                        Text("Remove Team Goal")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(AppColors.danger)
                .disabled(game.ourScore == 0)
            }
            
            // Second row - Opponent actions
            HStack(spacing: 12) {
                // Opponent goal button
                Button {
                    game.opponentScore += 1
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "soccerball.inverse")
                            .font(.title2)
                        Text("Opponent Goal")
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.coral)
                
                // Remove opponent goal button
                Button {
                    showingOpponentGoalRemovalModal = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                        Text("Subtract Opponent Goal")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(AppColors.danger)
                .disabled(game.opponentScore == 0)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Players (\(game.playerStats.count))")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                
                Spacer()
                
                Text("Tap row for details")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(game.playerStats.sorted(by: { $0.number < $1.number })) { playerStats in
                        PlayerStatRow(playerStats: playerStats) {
                            selectedPlayerForStats = playerStats
                            showingPlayerStatsModal = true
                        }
                    }
                }
            }
        }
        .padding(.top)
    }
}

struct PlayerStatRow: View {
    @ObservedObject var playerStats: PlayerStats
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Player number and position
                VStack(spacing: 2) {
                    Text("#\(playerStats.number)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                    Text(playerStats.position.abbreviation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                
                // Player name
                VStack(alignment: .leading, spacing: 2) {
                    Text(playerStats.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    if playerStats.isSubstituted {
                        Text("SUBSTITUTED")
                            .font(.caption2)
                            .foregroundColor(AppColors.orange)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                // Quick stats
                HStack(spacing: 12) {
                    if playerStats.goals > 0 {
                        StatBadge(icon: "soccerball", value: playerStats.goals, color: AppColors.primary)
                            .accessibilityLabel("\(playerStats.goals) goals")
                    }
                    if playerStats.assists > 0 {
                        StatBadge(icon: "hand.thumbsup", value: playerStats.assists, color: AppColors.darkBlue)
                            .accessibilityLabel("\(playerStats.assists) assists")
                    }
                    if playerStats.yellowCards > 0 {
                        StatBadge(icon: "rectangle", value: playerStats.yellowCards, color: AppColors.orange)
                            .accessibilityLabel("\(playerStats.yellowCards) yellow cards")
                    }
                    if playerStats.redCards > 0 {
                        StatBadge(icon: "rectangle.fill", value: playerStats.redCards, color: AppColors.danger)
                            .accessibilityLabel("\(playerStats.redCards) red cards")
                    }
                    if playerStats.saves > 0 {
                        StatBadge(icon: "hand.raised", value: playerStats.saves, color: AppColors.darkGreen)
                            .accessibilityLabel("\(playerStats.saves) saves")
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
    }
}

struct StatBadge: View {
    let icon: String
    let value: Int
    let color: Color
    
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
        .background(color.opacity(0.15))
        .cornerRadius(4)
    }
}

struct PlayerStatsDetailView: View {
    @ObservedObject var playerStats: PlayerStats
    @ObservedObject var game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Player header
                VStack(spacing: 8) {
                    Text("#\(playerStats.number)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary)
                    
                    Text(playerStats.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(playerStats.position.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                
                // Stats grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatButton(label: "Goals", value: $playerStats.goals) {
                        game.ourScore += 1
                    } onDecrement: {
                        if game.ourScore > 0 { game.ourScore -= 1 }
                    }
                    
                    StatButton(label: "Assists", value: $playerStats.assists)
                    
                    StatButton(label: "Yellow Cards", value: $playerStats.yellowCards)
                    
                    StatButton(label: "Red Cards", value: $playerStats.redCards)
                    
                    if playerStats.position == .goalkeeper {
                        StatButton(label: "Saves", value: $playerStats.saves)
                    }
                    
                    StatButton(label: "Shots", value: $playerStats.totalShots)
                }
                .padding(.horizontal)
                
                // Substitution toggle
                Toggle("Substituted", isOn: $playerStats.isSubstituted)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Player Stats")
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
}

// MARK: - Goal Assignment View
struct GoalAssignmentView: View {
    @ObservedObject var game: Game
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlayer: PlayerStats?
    @State private var assistingPlayer: PlayerStats?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Who scored the goal?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Unknown goal option
                        Button {
                            game.unknownGoals += 1
                            game.ourScore += 1
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .font(.title2)
                                    .foregroundColor(AppColors.orange)
                                
                                VStack(alignment: .leading) {
                                    Text("Unknown Player")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("No goal scorer selected")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        // Player options
                        ForEach(game.playerStats.sorted(by: { $0.number < $1.number })) { player in
                            PlayerGoalAssignmentRow(
                                player: player,
                                isSelected: selectedPlayer?.id == player.id
                            ) {
                                selectedPlayer = player
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if let selectedPlayer = selectedPlayer {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Assist by:")
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // No assist option
                                Button("No Assist") {
                                    assistingPlayer = nil
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(assistingPlayer == nil ? AppColors.primary : Color(.systemGray5))
                                .foregroundColor(assistingPlayer == nil ? .white : .primary)
                                .cornerRadius(8)
                                
                                ForEach(game.playerStats.filter { $0.id != selectedPlayer.id }.sorted(by: { $0.number < $1.number })) { player in
                                    Button("#\(player.number) \(player.name)") {
                                        assistingPlayer = player
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(assistingPlayer?.id == player.id ? AppColors.darkBlue : Color(.systemGray5))
                                    .foregroundColor(assistingPlayer?.id == player.id ? .white : .primary)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Button("Confirm Goal") {
                            selectedPlayer.goals += 1
                            if let assist = assistingPlayer {
                                assist.assists += 1
                            }
                            game.ourScore += 1
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primary)
                        .font(.headline)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Goal Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlayerGoalAssignmentRow: View {
    @ObservedObject var player: PlayerStats
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? AppColors.primary : .secondary)
                
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
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(player.goals) goals this game")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? AppColors.primary.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Goal Removal View
struct GoalRemovalView: View {
    @ObservedObject var game: Game
    @Environment(\.dismiss) private var dismiss
    
    var goalSources: [(String, () -> Void)] {
        var sources: [(String, () -> Void)] = []
        
        // Add players with goals
        for player in game.playerStats.filter({ $0.goals > 0 }).sorted(by: { $0.number < $1.number }) {
            sources.append(("#\(player.number) \(player.name) (\(player.goals) goals)", {
                player.goals -= 1
                game.ourScore = max(0, game.ourScore - 1)
            }))
        }
        
        // Add unknown goals if any
        if game.unknownGoals > 0 {
            sources.append(("Unknown Player (\(game.unknownGoals) goals)", {
                game.unknownGoals -= 1
                game.ourScore = max(0, game.ourScore - 1)
            }))
        }
        
        return sources
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if goalSources.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.orange)
                        
                        Text("No Goals to Remove")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("There are currently no goals recorded for your team.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    Text("Select a goal to remove:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(goalSources.enumerated()), id: \.offset) { index, source in
                                Button {
                                    source.1() // Execute the removal action
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: "minus.circle")
                                            .font(.title2)
                                            .foregroundColor(AppColors.danger)
                                        
                                        Text(source.0)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Remove Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Opponent Goal Removal View
struct OpponentGoalRemovalView: View {
    @ObservedObject var game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if game.opponentScore == 0 {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.orange)
                        
                        Text("No Goals to Remove")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("There are currently no goals recorded for \(game.opponentName).")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    Text("Subtract a goal from \(game.opponentName)?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    VStack(spacing: 20) {
                        // Current opponent score display
                        VStack(spacing: 8) {
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(game.opponentScore)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.coral)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Remove goal button
                        Button {
                            game.opponentScore = max(0, game.opponentScore - 1)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                
                                Text("Undo Goal")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.danger)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Text("This will reduce \(game.opponentName)'s score by 1")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Remove Opponent Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
