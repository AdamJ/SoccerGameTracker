import SwiftUI

struct EndGameConfirmationView: View {
    let ourScore: Int
    let opponentScore: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "flag.checkered")
                    .font(.system(size: 70))
                    .foregroundColor(AppColors.primary)
                
                // Title
                Text("End Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Final Score Display
                VStack(spacing: 12) {
                    Text("Final Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("HOME")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Text("\(ourScore)")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Text(":")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 4) {
                            Text("AWAY")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Text("\(opponentScore)")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.coral)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                Text("Are you sure you want to end this game?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        onConfirm()
                        dismiss()
                    } label: {
                        Text("Confirm")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.danger)
                    
                    Button {
                        onCancel()
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct EndGameConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        EndGameConfirmationView(
            ourScore: 3,
            opponentScore: 2,
            onConfirm: {},
            onCancel: {}
        )
    }
}
#endif
