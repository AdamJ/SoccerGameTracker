import SwiftUI

struct AddPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var rosterManager: RosterManager
    @FocusState private var isNameFieldFocused: Bool

    @State private var name: String = ""
    @State private var number: String = ""
    @State private var position: Position = .forward
    @State private var isSubstitute: Bool = false
    @State private var showingGKAlert = false
    @State private var showingLineupFullAlert = false

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
                        Text("This player will be added to the substitutes bench.")
                            .font(.caption)
                            .foregroundColor(SemanticColors.textSecondary)
                    } else if rosterManager.isStartingLineupFull() {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(SemanticColors.warning)
                            Text("Starting lineup is full. Player will be added as substitute.")
                                .font(.caption)
                                .foregroundColor(SemanticColors.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Add New Player")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { savePlayer() }.disabled(name.isEmpty || number.isEmpty) }
            }
            .alert("Goalkeeper Limit", isPresented: $showingGKAlert) {
                Button("OK") {}
            } message: {
                Text("You can only have one Goalkeeper in the starting lineup.")
            }
            .alert("Starting Lineup Full", isPresented: $showingLineupFullAlert) {
                Button("Add as Substitute") {
                    isSubstitute = true
                    savePlayer()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The starting lineup is full (\(rosterManager.teamFormat.maxPlayers) players). Would you like to add this player as a substitute?")
            }
        }
    }

    private func savePlayer() {
        guard let jerseyNumber = Int(number) else { return }

        // Check if trying to add to starting lineup when it's full
        if !isSubstitute && rosterManager.isStartingLineupFull() {
            showingLineupFullAlert = true
            return
        }

        // Only validate GK if going to STARTING lineup
        if position == .goalkeeper && !isSubstitute {
            if !rosterManager.canAddGoalkeeper() {
                showingGKAlert = true
                return
            }
        }

        rosterManager.addPlayer(name: name, number: jerseyNumber, position: position, isSubstitute: isSubstitute)
        presentationMode.wrappedValue.dismiss()
    }
}
