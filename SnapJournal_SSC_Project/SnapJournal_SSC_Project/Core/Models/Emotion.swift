//
//  Emotion.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import Foundation
import SwiftUI

struct Emotion: Identifiable {
    let id = UUID()
    let name: String
    let gradient: [Color]
    let description: String

    var baseTint: Color {
        gradient.first?.opacity(0.10) ?? Color.clear
    }

    var accentTint: Color {
        gradient.first?.opacity(0.25) ?? Color.clear
    }

    var softGradient: LinearGradient {
        LinearGradient(
            colors: gradient.map { $0.opacity(0.85) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private func ec(_ r: Double, _ g: Double, _ b: Double) -> Color {
    Color(red: r, green: g, blue: b).opacity(0.75)
}

let emotionList: [Emotion] = [
    Emotion(
        name: "Calm",
        gradient: [ec(0.32, 0.70, 0.52), ec(0.45, 0.82, 0.65)],
        description: "Green represents balance, calmness, and stability."
    ),
    Emotion(
        name: "Reflective",
        gradient: [ec(0.25, 0.55, 0.85), ec(0.45, 0.70, 0.95)],
        description: "Blue represents depth, thoughtfulness, and quiet reflection."
    ),
    Emotion(
        name: "Joyful",
        gradient: [ec(0.95, 0.75, 0.20), ec(1.00, 0.85, 0.35)],
        description: "Yellow represents happiness, warmth, and optimism."
    ),
    Emotion(
        name: "Energized",
        gradient: [ec(1.00, 0.55, 0.20), ec(1.00, 0.35, 0.20)],
        description: "Orange represents enthusiasm, movement, and creative energy."
    ),
    Emotion(
        name: "Passionate",
        gradient: [ec(0.85, 0.20, 0.30), ec(1.00, 0.35, 0.45)],
        description: "Red represents intensity, passion, and strong emotion."
    ),
    Emotion(
        name: "Nostalgic",
        gradient: [ec(0.55, 0.45, 0.85), ec(0.75, 0.60, 0.95)],
        description: "Purple represents imagination, emotion, and meaningful memories."
    ),
    Emotion(
        name: "Drained",
        gradient: [ec(0.55, 0.55, 0.60), ec(0.70, 0.70, 0.75)],
        description: "Gray represents heaviness, fatigue, or emotional stillness."
    ),
    Emotion(
        name: "Peaceful",
        gradient: [Color.white.opacity(0.75), ec(0.92, 0.92, 0.92)],
        description: "White represents clarity, simplicity, and acceptance."
    ),
    Emotion(
        name: "Worried",
        gradient: [ec(0.20, 0.68, 0.75), ec(0.10, 0.52, 0.62)],
        description: "Teal represents unease, restlessness, and a racing mind."
    ),
    Emotion(
        name: "Grateful",
        gradient: [ec(0.95, 0.72, 0.48), ec(0.88, 0.58, 0.35)],
        description: "Peach represents appreciation, warmth, and a full heart."
    )
]
