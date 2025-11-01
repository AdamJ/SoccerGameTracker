import SwiftUI

struct AddPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var rosterManager: RosterManager
    @FocusState private var isNameFieldFocused: Bool

    @State private var name: String = ""
    @State private var number: String = ""
    @State private var position: Position = .forward
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
