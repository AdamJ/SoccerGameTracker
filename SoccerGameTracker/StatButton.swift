//
//  StatButton.swift
//  SoccerGameTracker
//
//  Created by Adam Jolicoeur on 11/1/25.
//

import SwiftUI

/// Reusable stat counter component with increment/decrement functionality
struct StatButton: View {
    // MARK: - Properties
    let label: String
    @Binding var value: Int
    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?

    private var isDecrementEnabled: Bool { value > 0 }

    // MARK: - Body
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(label)
                .font(.caption)
                .foregroundColor(SemanticColors.textSecondary)
                .accessibilityHidden(true)

            HStack(spacing: DesignTokens.Spacing.md) {
                // Decrement button
                Button {
                    decrementValue()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(isDecrementEnabled ? SemanticColors.error : SemanticColors.textTertiary)
                }
                .disabled(!isDecrementEnabled)
                .accessibilityLabel("Decrease \(label)")
                .accessibilityHint("Current value is \(value)")

                // Value display
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(SemanticColors.textPrimary)
                    .frame(minWidth: 32)
                    .accessibilityHidden(true)

                // Increment button
                Button {
                    incrementValue()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(SemanticColors.secondary)
                }
                .accessibilityLabel("Increase \(label)")
                .accessibilityHint("Current value is \(value)")
            }
        }
        .buttonStyle(.borderless)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                incrementValue()
            case .decrement:
                if isDecrementEnabled {
                    decrementValue()
                }
            @unknown default:
                break
            }
        }
    }

    // MARK: - Private Methods
    private func incrementValue() {
        value += 1
        onIncrement?()
    }

    private func decrementValue() {
        guard value > 0 else { return }
        value -= 1
        onDecrement?()
    }
}
