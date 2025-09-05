//
//  SoccerGameTrackerApp.swift
//  SoccerGameTracker
//
//  Created by Adam Jolicoeur on 9/2/25.
//

import SwiftUI
import Combine

// --- DATA MODELS ---

enum Position: String, CaseIterable, Codable, Hashable {
    case goalkeeper = "Goalkeeper (GK)"
    case defense = "Defense (DF)"
    case midfield = "Midfield (MF)"
    case attack = "Attack (AT)"
    case substitute = "Substitute (SUB)"
}

enum GameHalf: String, Codable {
    case first = "1st Half"
    case second = "2nd Half"
}

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var number: Int
    var position: Position
    
    init(id: UUID = UUID(), name: String, number: Int, position: Position) {
        self.id = id
        self.name = name
        self.number = number
        self.position = position
    }
}

struct PlayerStats: Identifiable, Codable {
    let id: UUID
    var name: String
    var number: Int
    var position: Position
    var goals: Int = 0
    var assists: Int = 0
    var totalShots: Int = 0
    var saves: Int = 0
}

class Game: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var opponentName: String
    @Published var gameDate: Date
    @Published var location: String
    @Published var durationInSeconds: Int
    
    @Published var ourScore: Int
    @Published var opponentScore: Int
    @Published var playerStats: [PlayerStats]
    @Published var currentHalf: GameHalf
    
    @Published var unknownGoals: Int = 0 // Track goals with unknown scorer
    // Timer Properties (Transient - not saved)
    @Published var remainingSeconds: Int
    @Published var isTimerRunning = false
    private var timerCancellable: AnyCancellable?

    // Initializer for starting a new game
    init(opponentName: String, gameDate: Date, location: String, roster: [Player], durationInSeconds: Int) {
        self.id = UUID()
        self.opponentName = opponentName
        self.gameDate = gameDate
        self.location = location
        self.durationInSeconds = durationInSeconds
        self.remainingSeconds = durationInSeconds
        self.ourScore = 0
        self.opponentScore = 0
        self.currentHalf = .first
        self.playerStats = roster.map { player in
            PlayerStats(id: player.id, name: player.name, number: player.number, position: player.position)
        }
    }
    
    // --- Codable Conformance for Saving/Loading ---
    enum CodingKeys: String, CodingKey {
        case id, opponentName, gameDate, location, durationInSeconds, ourScore, opponentScore, playerStats, remainingSeconds, currentHalf, unknownGoals
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        opponentName = try container.decode(String.self, forKey: .opponentName)
        gameDate = try container.decode(Date.self, forKey: .gameDate)
        location = try container.decode(String.self, forKey: .location)
        durationInSeconds = try container.decode(Int.self, forKey: .durationInSeconds)
        ourScore = try container.decode(Int.self, forKey: .ourScore)
        opponentScore = try container.decode(Int.self, forKey: .opponentScore)
        playerStats = try container.decode([PlayerStats].self, forKey: .playerStats)
        remainingSeconds = try container.decode(Int.self, forKey: .remainingSeconds)
        currentHalf = try container.decode(GameHalf.self, forKey: .currentHalf)
        unknownGoals = (try? container.decode(Int.self, forKey: .unknownGoals)) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(opponentName, forKey: .opponentName)
        try container.encode(gameDate, forKey: .gameDate)
        try container.encode(location, forKey: .location)
        try container.encode(durationInSeconds, forKey: .durationInSeconds)
        try container.encode(ourScore, forKey: .ourScore)
        try container.encode(opponentScore, forKey: .opponentScore)
        try container.encode(playerStats, forKey: .playerStats)
        try container.encode(remainingSeconds, forKey: .remainingSeconds)
        try container.encode(currentHalf, forKey: .currentHalf)
        try container.encode(unknownGoals, forKey: .unknownGoals)
    }

    // --- Timer Logic ---
    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
    }
    
    func endHalf() {
        stopTimer()
        if currentHalf == .first {
            self.remainingSeconds = self.durationInSeconds
            self.currentHalf = .second
        }
    }
    
    func timeString() -> String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// --- DATA & GAME MANAGERS ---

class RosterManager: ObservableObject {
    @Published var roster: [Player] = [] { didSet { saveRoster() } }
    @Published var homeTeamName: String = "HOME" { didSet { saveHomeTeamName() } }
    private let rosterKey = "SoccerRoster"
    private let homeTeamNameKey = "SoccerHomeTeamName"
    weak var gameManager: GameManager?
    init() {
        loadRoster()
        loadHomeTeamName()
    }
    
    func addPlayer(name: String, number: Int, position: Position) {
        roster.append(Player(name: name, number: number, position: position))
    }
    
    func updatePlayer(_ player: Player) {
        if let index = roster.firstIndex(where: { $0.id == player.id }) {
            roster[index] = player
            // Sync changes to active game if present
            gameManager?.syncPlayerToGame(player)
        }
    }
    
    func canAddGoalkeeper(ignoring playerID: UUID? = nil) -> Bool {
        let otherPlayers = roster.filter { $0.id != playerID }
        return !otherPlayers.contains { $0.position == .goalkeeper }
    }
    
    private func saveRoster() { if let data = try? JSONEncoder().encode(roster) { UserDefaults.standard.set(data, forKey: rosterKey) } }
    private func loadRoster() {
        guard let data = UserDefaults.standard.data(forKey: rosterKey), let decoded = try? JSONDecoder().decode([Player].self, from: data) else { return }
        self.roster = decoded
    }
    private func saveHomeTeamName() { UserDefaults.standard.set(homeTeamName, forKey: homeTeamNameKey) }
    private func loadHomeTeamName() {
        if let name = UserDefaults.standard.string(forKey: homeTeamNameKey) {
            homeTeamName = name
        }
    }
}

class GameHistoryManager: ObservableObject {
    @Published var gameHistory: [Game] = [] { didSet { saveHistory() } }
    private let historyKey = "SoccerGameHistory"
    init() { loadHistory() }
    
    func saveGame(_ game: Game) {
        game.stopTimer()
        gameHistory.insert(game, at: 0)
    }
    
    func deleteGames(withIDs ids: Set<UUID>) {
        gameHistory.removeAll { ids.contains($0.id) }
    }
    
    private func saveHistory() { if let data = try? JSONEncoder().encode(gameHistory) { UserDefaults.standard.set(data, forKey: historyKey) } }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey), let decoded = try? JSONDecoder().decode([Game].self, from: data) else { return }
        self.gameHistory = decoded
    }
}

class GameManager: ObservableObject {
    @Published var currentGame: Game?
    var isGameActive: Bool { currentGame != nil }
    
    /// The roster is locked if a game is active AND it's the first half, OR if it's the second half and the timer is running.
    var isRosterLocked: Bool {
        guard let game = currentGame else { return false }
        // Roster is locked during first half, or during second half ONLY if timer is running
        if game.currentHalf == .first { return true }
        if game.currentHalf == .second && game.isTimerRunning { return true }
        return false // Roster is editable after 1st half ends and timer is not running
    }
    
    func startGame(opponentName: String, gameDate: Date, location: String, roster: [Player], durationInSeconds: Int) {
        currentGame = Game(opponentName: opponentName, gameDate: gameDate, location: location, roster: roster, durationInSeconds: durationInSeconds)
    }
    
    func endGame() {
        currentGame?.stopTimer()
        currentGame = nil
    }
    
    // Sync player changes from roster to current game
    func syncPlayerToGame(_ player: Player) {
        guard let game = currentGame else { return }
        if let index = game.playerStats.firstIndex(where: { $0.id == player.id }) {
            game.playerStats[index].name = player.name
            game.playerStats[index].number = player.number
            game.playerStats[index].position = player.position
        }
    }
}

// --- UI VIEWS ---

// MARK: - PlayerEditView
struct PlayerEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var rosterManager: RosterManager
    @FocusState private var isNameFieldFocused: Bool
    
    @Binding var player: Player
    
    @State private var name: String = ""
    @State private var number: String = ""
    @State private var position: Position = .attack
    @State private var showingGKAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Details")) {
                    TextField("Player Name", text: $name)
                        .focused($isNameFieldFocused)
                    TextField("Jersey Number", text: $number).keyboardType(.numberPad)
                    Picker("Position", selection: $position) {
                        ForEach(Position.allCases, id: \.self) { pos in Text(pos.rawValue).tag(pos) }
                    }
                }
            }
            .navigationTitle("Edit Player")
            .onAppear {
                loadPlayerData()
                // Add a small delay for the keyboard to appear smoothly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { savePlayer() }.disabled(name.isEmpty || number.isEmpty) }
            }
            .alert("Goalkeeper Limit", isPresented: $showingGKAlert) { Button("OK") {} } message: {
                Text("You can only have one Goalkeeper on the roster.")
            }
        }
    }
    
    private func loadPlayerData() {
        name = player.name
        number = "\(player.number)"
        position = player.position
    }
    
    private func savePlayer() {
        if position == .goalkeeper && !rosterManager.canAddGoalkeeper(ignoring: player.id) {
            showingGKAlert = true
            return
        }
        
        if let jerseyNumber = Int(number) {
            player.name = name
            player.number = jerseyNumber
            player.position = position
            rosterManager.updatePlayer(player)
            presentationMode.wrappedValue.dismiss()
        }
    }
}


// MARK: - AddPlayerView
struct AddPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var rosterManager: RosterManager
    @FocusState private var isNameFieldFocused: Bool
    
    @State private var name: String = ""
    @State private var number: String = ""
    @State private var position: Position = .attack
    @State private var showingGKAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Details")) {
                    TextField("Player Name", text: $name)
                        .focused($isNameFieldFocused)
                    TextField("Jersey Number", text: $number).keyboardType(.numberPad)
                    Picker("Position", selection: $position) {
                        ForEach(Position.allCases, id: \.self) { pos in Text(pos.rawValue).tag(pos) }
                    }
                }
            }
            .navigationTitle("Add New Player")
            .onAppear {
                // Add a small delay for the keyboard to appear smoothly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { savePlayer() }.disabled(name.isEmpty || number.isEmpty) }
            }
            .alert("Goalkeeper Limit", isPresented: $showingGKAlert) { Button("OK") {} } message: {
                Text("You can only have one Goalkeeper on the roster.")
            }
        }
    }
    
    private func savePlayer() {
        if position == .goalkeeper && !rosterManager.canAddGoalkeeper() { showingGKAlert = true; return }
        if let jerseyNumber = Int(number) {
            rosterManager.addPlayer(name: name, number: jerseyNumber, position: position)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - RosterView
struct RosterView: View {
    @EnvironmentObject var gameManager: GameManager
    @ObservedObject var rosterManager: RosterManager
    @State private var isShowingAddPlayerSheet = false
    @State private var playerToEdit: Player?
    // Team name editing state
    @State private var isEditingTeamName = false
    @State private var editedTeamName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Text(rosterManager.homeTeamName)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(AppColors.darkGreen)
                    }
                    .padding(.top, 8)
                    .sheet(isPresented: $isEditingTeamName) {
                        NavigationView {
                            Form {
                                Section(header: Text("Team Name")) {
                                    TextField("Enter a Team Name", text: $editedTeamName)
                                        .autocapitalization(.words)
                                }
                            }
                            .navigationTitle("Edit Team Name")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Cancel") { isEditingTeamName = false }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Save") {
                                        let trimmed = editedTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if !trimmed.isEmpty {
                                            rosterManager.homeTeamName = trimmed
                                        }
                                        isEditingTeamName = false
                                    }.disabled(editedTeamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                            }
                        }
                    }
                }
                List {
                    if gameManager.isRosterLocked {
                        Section {
                            Text("Roster changes can be made at halftime or when the timer is paused.")
                                .foregroundColor(AppColors.blue)
                        }
                    }
                    ForEach(Position.allCases, id: \ .self) { position in
                        let playersInPosition = rosterManager.roster.filter { $0.position == position }
                        if !playersInPosition.isEmpty {
                            Section(header: Text(position.rawValue)) {
                                ForEach(playersInPosition) { player in
                                    Button(action: { if !gameManager.isRosterLocked { playerToEdit = player } }) {
                                        HStack {
                                            Text("\(player.number)").font(.headline).frame(width: 40)
                                            Text(player.name).font(.headline)
                                            Spacer()
                                            if !gameManager.isRosterLocked {
                                                Image(systemName: "chevron.right").foregroundColor(AppColors.blue)
                                            }
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                                .onDelete(perform: gameManager.isRosterLocked ? nil : { indexSet in deletePlayer(at: indexSet, from: playersInPosition) })
                            }
                        }
                    }
                }
                .overlay {
                    if rosterManager.roster.isEmpty {
                        ContentUnavailableView {
                            Label("No Players", systemImage: "person.slash")
                        }
                        description: {
                            Text("There are no players currently on the roster.\nTap the + button to add players.")
                        }
                        .background(.clear)
                    }
                }
                .navigationTitle("Team Roster")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Add Player", action: { isShowingAddPlayerSheet.toggle() })
                                .disabled(gameManager.isRosterLocked)
                            Button("Edit Team Name", action: {
                                editedTeamName = rosterManager.homeTeamName
                                isEditingTeamName = true
                            })
                        } label: {
                            Label("Roster Options", systemImage: "slider.vertical.3")
                        }
                    }
                }
                .sheet(isPresented: $isShowingAddPlayerSheet) { AddPlayerView(rosterManager: rosterManager) }
                .sheet(item: $playerToEdit) { player in
                    if let index = rosterManager.roster.firstIndex(where: { $0.id == player.id }) {
                        PlayerEditView(rosterManager: rosterManager, player: $rosterManager.roster[index])
                    }
                }
            }
        }
    }
    
    private func deletePlayer(at offsets: IndexSet, from positionGroup: [Player]) {
        let playersToDelete = offsets.map { positionGroup[$0] }
        rosterManager.roster.removeAll { player in playersToDelete.contains { $0.id == player.id } }
    }
}

// MARK: - GameSetupView - Pre-Game Setup
struct GameSetupView: View {
    @EnvironmentObject var gameManager: GameManager
    @ObservedObject var rosterManager: RosterManager
    
    @State private var opponentName: String = ""
    @State private var location: String = ""
    @State private var gameDate: Date = Date()
    @State private var selectedDurationIndex = 4
    // Default to 20 minutes - each number equals a jump in 5 minutes, starting at 0
    // Example 0 = 5 minutes, 2 = 15 minutes, 3 = 20 minutes, etc.
    
    let durationOptions = Array(stride(from: 5, through: 45, by: 5))

    var body: some View {
        NavigationView {
            if let game = gameManager.currentGame {
                GameTrackerView(game: game)
            } else {
                Form {
                    Section(header: Text("Game Details")) {
                        TextField("Opponent Name", text: $opponentName)
                        TextField("Location", text: $location)
                        DatePicker("Date and Time", selection: $gameDate)
                        Picker("Half Length", selection: $selectedDurationIndex) {
                            ForEach(0..<durationOptions.count, id: \.self) { index in Text("\(durationOptions[index]) minutes").tag(index) }
                        }
                    }
                    if rosterManager.roster.isEmpty {
                        Section(header: Text("Game Actions")) {
                            Text("You must add at least one player to the roster before a game can be started.").foregroundColor(AppColors.orange).font(.subheadline)
                            Button("Start Game") { startGame() }.disabled(opponentName.isEmpty || rosterManager.roster.isEmpty)
                        }
                    } else {
                        Section(header: Text("Game Actions")) {
                            Button("Start Game") { startGame() }.disabled(opponentName.isEmpty || rosterManager.roster.isEmpty)
                        }
                    }
//                    Button("Start Game") { startGame() }.disabled(opponentName.isEmpty || rosterManager.roster.isEmpty)
//                    if rosterManager.roster.isEmpty { Text("You must add at least one player to the roster before a game can be started.").foregroundColor(AppColors.danger).font(.caption) }
                }
                .navigationTitle("Game Setup")
            }
        }
    }
    
    private func startGame() {
        let durationInSeconds = durationOptions[selectedDurationIndex] * 60
        gameManager.startGame(opponentName: opponentName, gameDate: gameDate, location: location, roster: rosterManager.roster, durationInSeconds: durationInSeconds)
    }
}

// MARK: - GameTrackerView - Live Game
struct GameTrackerView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rosterManager: RosterManager
    @StateObject var game: Game
    @State private var showingEndGameSheet = false
    @State private var showingCancelAlert = false

    var body: some View {
        VStack {
            // Scoreboard & Timer
            VStack {
                HStack {
                    VStack {
                        Text(rosterManager.homeTeamName).font(.headline)
                        HStack {
                            Button {
                                if game.ourScore > 0 && game.unknownGoals > 0 {
                                    game.ourScore -= 1
                                    game.unknownGoals -= 1
                                }
                            } label: { Image(systemName: "minus.circle") }
                            Text("\(game.ourScore)").font(.system(size: 40, weight: .bold))
                            Button {
                                game.ourScore += 1
                                game.unknownGoals += 1
                            } label: { Image(systemName: "plus.circle") }
                        }.font(.title2)
                    }
                    Spacer()
                    VStack {
                        Text(game.currentHalf.rawValue).font(.system(size: 14, weight: .bold, design: .default)).foregroundColor(AppColors.darkGreen)
                         Text(game.timeString()).font(.system(size: 32, weight: .bold, design: .monospaced))
                        Button(action: { game.isTimerRunning ? game.stopTimer() : game.startTimer() }) {
                            Image(systemName: game.isTimerRunning ? "stop.circle" : "timer").font(.largeTitle)
                        }
                    }
                    Spacer()
                    VStack {
                        Text(game.opponentName.uppercased()).font(.headline)
                        HStack {
                            Button { if game.opponentScore > 0 { game.opponentScore -= 1 } } label: { Image(systemName: "minus.circle") }
                            Text("\(game.opponentScore)").font(.system(size: 40, weight: .bold))
                            Button { game.opponentScore += 1 } label: { Image(systemName: "plus.circle") }
                        }.font(.title2)
                    }
                }
            }
            .padding().background(AppColors.coral).cornerRadius(16).padding(.horizontal)

            List(Array($game.playerStats.enumerated()), id: \.element.id) { index, $stats in
                VStack(alignment: .leading) {
                    Text("\(stats.name) (\(stats.number))").font(.headline).foregroundColor(AppColors.primary).bold()
                    HStack(spacing: 0) {
                        if stats.position != .goalkeeper {
                            StatButton(label: "Goals", value: $stats.goals, onIncrement: { game.ourScore += 1; stats.totalShots += 1 }, onDecrement: { if game.ourScore > 0 { game.ourScore -= 1 }; if stats.totalShots > 0 { stats.totalShots -= 1 } })
                            Spacer()
                            StatButton(label: "Shots", value: $stats.totalShots)
                            Spacer()
                            StatButton(label: "Assists", value: $stats.assists)
                        } else {
                            StatButton(label: "Saves", value: $stats.saves)
                        }
                    }
                }
                .listRowBackground(colorScheme == .dark ? Color.black : Color.white.opacity(0.9))
            }
            .scrollContentBackground(.hidden)
//            .background {
//                Image("SoccerField")
//                    .resizable()
////                    .scaledToFill()
//                    .opacity(0.5)
//                    .ignoresSafeArea()
//            }
//            .background(AppColors.fieldBackground.ignoresSafeArea().opacity(0.75))
            .listStyle(.automatic)
            .listRowSeparator(.hidden)
            .listRowSpacing(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures the background fills the entire space
        .background {
            Image("SoccerField")
                .resizable()
//                    .scaledToFill()
                .opacity(0.5)
                .ignoresSafeArea()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.black, AppColors.fieldBackground]), startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea().opacity(0.95))
        .navigationTitle("Live Game").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("End Half", action: { game.endHalf() })
                        .disabled(game.currentHalf != .first)
                    Button("End Game", role: .destructive, action: { showingEndGameSheet = true })
                    Button("Cancel Game", role: .destructive, action: { showingCancelAlert = true }) // Add Cancel Game option
                } label: { Text("Game Options") }
            }
        }
        .sheet(isPresented: $showingEndGameSheet) { GameSummaryView(game: game, isNewGame: true, isPresented: $showingEndGameSheet) }
        .alert("Cancel Game?", isPresented: $showingCancelAlert) {
            Button("Cancel Game", role: .destructive) {
                // End and clear game without saving to history
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    // Dismiss to root view (GameSetupView will show)
                    (windowScene.windows.first { $0.isKeyWindow })?.rootViewController?.dismiss(animated: true)
                }
                // Use NotificationCenter to notify ContentView to clear game
                NotificationCenter.default.post(name: .cancelGame, object: nil)
            }
            Button("Keep Playing", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this game? All progress will be lost and nothing will be saved.")
        }
    }
}

// Notification for canceling game
extension Notification.Name {
    static let cancelGame = Notification.Name("CancelGameNotification")
}

// MARK: - GameSummaryView
struct GameSummaryView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var historyManager: GameHistoryManager
    @EnvironmentObject var rosterManager: RosterManager
    @ObservedObject var game: Game
    var isNewGame: Bool // To control save button visibility
    @Binding var isPresented: Bool // Add binding to control sheet dismissal

    var body: some View {
        NavigationView {
            VStack {
                Text("Final Score").font(.largeTitle).padding()
                HStack(spacing: 30) {
                    VStack { Text(rosterManager.homeTeamName).font(.headline); Text("\(game.ourScore)").font(.system(size: 60, weight: .bold)) }
                    Text("vs").font(.title)
                    VStack { Text(game.opponentName.uppercased()).font(.headline); Text("\(game.opponentScore)").font(.system(size: 60, weight: .bold)) }
                }.padding(.bottom, 30)
                
                List {
                    Section(header: Text("Player Statistics")) {
                        ForEach(game.playerStats.filter { $0.goals > 0 || $0.assists > 0 || $0.saves > 0 || $0.totalShots > 0 }) { stats in
                            HStack {
                                Text("\(stats.name) (#\(stats.number))"); Spacer()
                                if stats.position != .goalkeeper {
                                    Text("G:\(stats.goals) S:\(stats.totalShots) A:\(stats.assists)").foregroundColor(AppColors.blue)
                                } else {
                                    Text("SV:\(stats.saves)").foregroundColor(AppColors.blue)
                                }
                            }
                            if stats.goals < 1 {
                                
                            }
                        }
                        if game.unknownGoals > 0 {
                            HStack {
                                Text("Unassigned").italic(); Spacer()
                                Text("G:\(game.unknownGoals)").foregroundColor(AppColors.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Game Summary").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ShareLink(item: generateCSVString(),
                              subject: Text("Soccer Game Stats"),
                              message: Text("Stats from game on \(game.gameDate.formatted(date: .abbreviated, time: .omitted)) vs \(game.opponentName)"),
                              preview: SharePreview("Game Stats vs \(game.opponentName)")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isNewGame {
                        Button("Save & Close") {
                            historyManager.saveGame(game)
                            gameManager.endGame()
                            isPresented = false // Dismiss sheet
                        }
                    } else {
                        Button("Close") { isPresented = false } // Dismiss sheet
                    }
                }
            }
        }
    }
    
    private func generateCSVString() -> String {
        var csvString = "Player Name,Number,Position,Goals,Total Shots,Assists,Saves\n"
        for stats in game.playerStats {
            csvString += "\(stats.name),\(stats.number),\(stats.position.rawValue),\(stats.goals),\(stats.totalShots),\(stats.assists),\(stats.saves)\n"
        }
        return csvString
    }
}

// MARK: - GameHistoryView
struct GameHistoryView: View {
    @EnvironmentObject var historyManager: GameHistoryManager
    @Environment(\.editMode) private var editMode
    
    @State private var selectedGame: Game?
    @State private var selection = Set<UUID>()
    @State private var showingDeleteAlert = false
    @State private var gameIDsToDelete = Set<UUID>()

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selection) {
                    ForEach(historyManager.gameHistory) { game in
                        Button(action: { if editMode?.wrappedValue == .inactive { selectedGame = game } }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("vs \(game.opponentName)").font(.headline)
                                    Text(game.gameDate.formatted(date: .long, time: .shortened)).font(.caption).foregroundColor(AppColors.blue)
                                }
                                Spacer()
                                Text("\(game.ourScore) - \(game.opponentScore)").font(.title).bold()
                            }
                            .foregroundColor(.primary)
                        }
                        .tag(game.id)
                    }
                    .onDelete(perform: onDelete)
                }
            }
            .navigationTitle("Game History")
            .sheet(item: $selectedGame) { game in
                GameSummaryView(game: game, isNewGame: false, isPresented: Binding(get: { selectedGame != nil }, set: { if !$0 { selectedGame = nil } }))
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete", role: .destructive) {
                        self.gameIDsToDelete = self.selection
                        self.showingDeleteAlert = true
                    }
                    .disabled(selection.isEmpty)
                }
//                if editMode?.wrappedValue.isEditing == true {
//
//                }
            }
            .alert("Confirm Deletion", isPresented: $showingDeleteAlert, presenting: gameIDsToDelete) { _ in
                Button("Delete", role: .destructive, action: performDelete)
                Button("Cancel", role: .cancel) { gameIDsToDelete.removeAll() }
            } message: { ids in
                Text("Are you sure you want to delete \(ids.count) game(s)? This action cannot be undone.")
            }
        }
    }

    private func onDelete(at offsets: IndexSet) {
        let idsToDelete = offsets.map { historyManager.gameHistory[$0].id }
        self.gameIDsToDelete = Set(idsToDelete)
        self.showingDeleteAlert = true
    }

    private func performDelete() {
        historyManager.deleteGames(withIDs: gameIDsToDelete)
        gameIDsToDelete.removeAll()
        selection.removeAll()
    }
}

// A reusable button for incrementing/decrementing stats.
struct StatButton: View {
    let label: String
    @Binding var value: Int
//    Set enabled for items with value greater than 0
    var isEnabled: Bool { value > 0 }
    var onIncrement: (() -> Void)? = nil
    var onDecrement: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            Text(label).font(.caption)
            HStack {
                Button {
                    if value > 0 { value -= 1; onDecrement?() }
                } label: {
                    Image(systemName: "minus.circle")
                }
                .foregroundColor(isEnabled ? AppColors.danger : .gray)
                .disabled(!isEnabled)
                Text("\(value)").font(.headline).frame(width: 25)
                Button {
                    value += 1; onIncrement?()
                } label: {
                    Image(systemName: "plus.circle")
                }
                .foregroundStyle(AppColors.darkBlue)
            }
        }.buttonStyle(BorderlessButtonStyle())
    }
}

// MARK: - ContentView (Main App Screen)
struct ContentView: View {
    @StateObject private var rosterManager = RosterManager()
    @StateObject private var gameManager = GameManager()
    @StateObject private var historyManager = GameHistoryManager()

    var body: some View {
        TabView {
            GameSetupView(rosterManager: rosterManager)
                .tabItem { Label("Game", systemImage: "sportscourt") }
            RosterView(rosterManager: rosterManager)
                .tabItem { Label("Roster", systemImage: "person.3.fill") }
            GameHistoryView()
                .tabItem { Label("History", systemImage: "trophy.fill") }
        }
        .environmentObject(gameManager)
        .environmentObject(historyManager)
        .environmentObject(rosterManager)
        .onAppear {
            rosterManager.gameManager = gameManager
            NotificationCenter.default.addObserver(forName: .cancelGame, object: nil, queue: .main) { _ in
                gameManager.endGame() // Clear current game
            }
        }
    }
}

// --- APP ENTRY POINT ---
@main
struct SoccerTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if DEBUG
final class PreviewManagers: ObservableObject {
    let rosterManager: RosterManager
    let gameManager: GameManager
    let historyManager: GameHistoryManager

    init(populated: Bool) {
        rosterManager = RosterManager()
        gameManager = GameManager()
        historyManager = GameHistoryManager()

        if populated {
            // 11-player roster
            rosterManager.roster = [
                Player(name: "Alex Morgan", number: 1, position: .goalkeeper),
                Player(name: "Ben Carter", number: 24, position: .defense),
                Player(name: "Carlos Vega", number: 3, position: .defense),
                Player(name: "Diego Ramos", number: 40, position: .defense),
                Player(name: "Ethan Park", number: 5, position: .defense),
                Player(name: "Felix Hart", number: 62, position: .midfield),
                Player(name: "George Li", number: 7, position: .midfield),
                Player(name: "Hannah Kim", number: 88, position: .midfield),
                Player(name: "Ivy Smith", number: 19, position: .midfield),
                Player(name: "Jack Turner", number: 10, position: .attack),
                Player(name: "Liam Young", number: 11, position: .attack),
                Player(name: "Arnold Yount", number: 18, position: .substitute),
            ]
            rosterManager.homeTeamName = "TIGERS"

            // Active game for populated preview
            let activeGame = Game(opponentName: "Rivals", gameDate: Date(), location: "United Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            activeGame.ourScore = 2
            activeGame.opponentScore = 1
            if activeGame.playerStats.indices.contains(8) { activeGame.playerStats[8].goals = 1 }
            if activeGame.playerStats.indices.contains(0) { activeGame.playerStats[0].saves = 2 }
            gameManager.currentGame = activeGame

            // Multiple past games in history
            let past1 = Game(opponentName: "Eagles", gameDate: Date().addingTimeInterval(-86400 * 3), location: "Away Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past1.ourScore = 3
            past1.opponentScore = 2
            if past1.playerStats.indices.contains(6) { past1.playerStats[6].goals = 2 }
            if past1.playerStats.indices.contains(5) { past1.playerStats[5].assists = 1 }

            let past2 = Game(opponentName: "Lions", gameDate: Date().addingTimeInterval(-86400 * 10), location: "United Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past2.ourScore = 1
            past2.opponentScore = 1
            if past2.playerStats.indices.contains(2) { past2.playerStats[2].saves = 1 }

            let past3 = Game(opponentName: "Panthers", gameDate: Date().addingTimeInterval(-86400 * 30), location: "Neutral", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past3.ourScore = 0
            past3.opponentScore = 2
            if past3.playerStats.indices.contains(0) { past3.playerStats[0].saves = 4 }

            let past4 = Game(opponentName: "Wolves", gameDate: Date().addingTimeInterval(-86400 * 60), location: "Away Field", roster: rosterManager.roster, durationInSeconds: 25 * 60)
            past4.ourScore = 4
            past4.opponentScore = 0
            if past4.playerStats.indices.contains(9) { past4.playerStats[9].goals = 2 }
            if past4.playerStats.indices.contains(10) { past4.playerStats[10].assists = 1 }
            if past4.playerStats.indices.contains(0) { past4.playerStats[0].saves = 1 }

            historyManager.gameHistory = [past1, past2, past3, past4]
        } else {
            // Empty / fresh install
            rosterManager.roster = []
            rosterManager.homeTeamName = "United"
            historyManager.gameHistory = []
        }

        rosterManager.gameManager = gameManager
    }
}

struct PopulatedPreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: true)
    var body: some View {
        ContentView()
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

struct EmptyPreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: false)
    var body: some View {
        ContentView()
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

// New preview: show the live GameTrackerView directly
struct LiveGamePreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: true)

    var body: some View {
        // Create an active game using the preview roster so the tracker shows populated player stats
        let activeGame = Game(opponentName: "Rivals", gameDate: Date(), location: "Home Field", roster: managers.rosterManager.roster, durationInSeconds: 25 * 60)
        activeGame.ourScore = 2
        activeGame.opponentScore = 1
        if activeGame.playerStats.indices.contains(8) { activeGame.playerStats[8].goals = 1 }
        if activeGame.playerStats.indices.contains(0) { activeGame.playerStats[0].saves = 2 }

        return GameTrackerView(game: activeGame)
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

// Preview: show the GameHistoryView directly
struct GameHistoryPreviewView: View {
    @StateObject private var managers = PreviewManagers(populated: true)
    var body: some View {
        GameHistoryView()
            .environmentObject(managers.gameManager)
            .environmentObject(managers.historyManager)
            .environmentObject(managers.rosterManager)
    }
}

struct SoccerTrackerApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PopulatedPreviewView()
                .previewDisplayName("Populated — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")

            LiveGamePreviewView()
                .previewDisplayName("Live Game — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")

            EmptyPreviewView()
                .previewDisplayName("Empty — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")

            GameHistoryPreviewView()
                .previewDisplayName("Game History — iPhone 16 Pro Max")
                .previewDevice("iPhone 16 Pro Max")
//            PopulatedPreviewView()
//                .previewDisplayName("Populated — iPad Pro 11-inch (M4)")
//                .previewDevice("iPad Pro 11-inch (M4)")
//            EmptyPreviewView()
//                .previewDisplayName("Empty — iPad Pro 11-inch (M4)")
//                .previewDevice("iPad Pro 11-inch (M4)")
        }
    }
}

#endif
