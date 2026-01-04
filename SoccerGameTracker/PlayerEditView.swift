import SwiftUI

struct PlayerEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var rosterManager: RosterManager
    @FocusState private var isNameFieldFocused: Bool
    @Binding var player: Player
    @State private var name: String = ""
    @State private var number: String = ""
    @State private var position: Position = .forward
    @State private var isSubstitute: Bool = false
    @State private var showingGKAlert = false
    @State private var showingGKSwapAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Details")) {
                    TextField("Player Name", text: $name)
                        .focused($isNameFieldFocused)
                    TextField("Jersey Number", text: $number).keyboardType(.numberPad)
                    Picker("Position", selection: $position) {
                        ForEach(Position.displayPositions, id: \.self) { pos in Text(pos.rawValue).tag(pos) }
                    }
                }

                Section(header: Text("Role")) {
                    Picker("Player Role", selection: $isSubstitute) {
                        Text("Starting Lineup").tag(false)
                        Text("Substitute").tag(true)
                    }
                    .pickerStyle(.segmented)

                    if isSubstitute {
                        Text("Substitute players retain their position and can be swapped with starters.")
                            .font(.caption)
                            .foregroundColor(SemanticColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Edit Player")
            .onAppear {
                loadPlayerData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { savePlayer() }.disabled(name.isEmpty || number.isEmpty) }
            }
            .alert("Goalkeeper Required", isPresented: $showingGKAlert) {
                Button("OK") {}
            } message: {
                Text("Your team must have at least one goalkeeper in the starting lineup.")
            }
            .alert("Goalkeeper Swap Required", isPresented: $showingGKSwapAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Swap Goalkeepers") {
                    performGoalkeeperSwap()
                }
            } message: {
                Text("Moving this goalkeeper to the starting lineup will automatically move the current starting goalkeeper to substitutes. Continue?")
            }
        }
    }
    private func loadPlayerData() {
        name = player.name
        number = "\(player.number)"
        position = player.position
        isSubstitute = player.isSubstitute
    }
    private func savePlayer() {
        guard let jerseyNumber = Int(number) else { return }

        // Check if moving only starting GK to substitutes
        if player.position == .goalkeeper && !player.isSubstitute && isSubstitute {
            let startingGKs = rosterManager.starters.filter { $0.position == .goalkeeper }
            if startingGKs.count == 1 {
                showingGKAlert = true
                return
            }
        }

        // Check if GK swap needed when moving to starters
        if position == .goalkeeper && !isSubstitute {
            if rosterManager.requiresGoalkeeperSwap(for: player, newPosition: position) {
                showingGKSwapAlert = true
                return
            }

            if !rosterManager.canAddGoalkeeper(ignoring: player.id) {
                showingGKAlert = true
                return
            }
        }

        // Prevent changing GK to different position if they're the only starting GK
        if player.position == .goalkeeper && !player.isSubstitute && position != .goalkeeper {
            let startingGKs = rosterManager.starters.filter { $0.position == .goalkeeper }
            if startingGKs.count == 1 {
                showingGKAlert = true
                return
            }
        }

        // Update player
        player.name = name
        player.number = jerseyNumber
        player.position = position
        player.isSubstitute = isSubstitute

        rosterManager.updatePlayer(player)
        presentationMode.wrappedValue.dismiss()
    }

    private func performGoalkeeperSwap() {
        guard let jerseyNumber = Int(number) else { return }

        player.name = name
        player.number = jerseyNumber
        player.position = .goalkeeper
        player.isSubstitute = false

        rosterManager.swapGoalkeepers(incomingGK: player)
        presentationMode.wrappedValue.dismiss()
    }
}
