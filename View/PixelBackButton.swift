//
//  PixelBackButton.swift
//  Shiddaha
//
//  Created by lama bin slmah on 14/02/2026.
//


// ═══════════════════════════════════════════════════════════════
// FILE 1: PixelBackButton.swift   ✅ (NEW - shared back button)
// ═══════════════════════════════════════════════════════════════

import SwiftUI

struct PixelBackButton: View {
    @Environment(\.dismiss) private var dismiss

    // Same exact style as Progress back button
    private let size: CGFloat = 30
    private let circleColor = Color(hex: "7D3B22")

    /// If you pass an action, it will run it. If not, it will dismiss automatically.
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            if let action { action() } else { dismiss() }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(circleColor)
                .clipShape(Circle())
        }
    }
}
