//
//  StatButton.swift
//  SoccerGameTracker
//
//  Created by Adam Jolicoeur on 11/1/25.
//


import SwiftUI

struct StatButton: View {
    let label: String
    @Binding var value: Int
    var isEnabled: Bool { value > 0 }
    var onIncrement: (() -> Void)? = nil
    var onDecrement: (() -> Void)? = nil

    var body: some View {
        VStack {
            Text(label).font(.caption).foregroundColor(.primary)
            HStack {
                Button {
                    if value > 0 { value -= 1; onDecrement?() }
                } label: {
                    Image(systemName: "minus.circle")
                }
                .foregroundColor(isEnabled ? AppColors.danger : Color(.systemGray3))
                .disabled(!isEnabled)
                Text("\(value)").font(.headline).frame(width: 25).foregroundColor(.primary)
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
