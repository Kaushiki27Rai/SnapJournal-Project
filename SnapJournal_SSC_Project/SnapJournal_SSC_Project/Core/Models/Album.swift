//
//  Album.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 21/02/26.
//

import Foundation
import SwiftUI

struct Album: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var stickerIcon: String
    var momentIDs: [UUID] = []
    var createdDate: Date = Date()

    func dominantEmotion(from moments: [Moment]) -> Emotion? {
        let assigned = moments.filter { momentIDs.contains($0.id) }
        guard !assigned.isEmpty else { return nil }
        var counts: [String: (emotion: Emotion, count: Int)] = [:]
        for moment in assigned {
            guard let emotion = moment.emotion else { continue }
            let existing = counts[emotion.name]
            counts[emotion.name] = (emotion, (existing?.count ?? 0) + 1)
        }
        return counts.values.max(by: { $0.count < $1.count })?.emotion
    }

    func spineGradient(from moments: [Moment]) -> [Color] {
        guard let emotion = dominantEmotion(from: moments) else {
            return [Color(UIColor.systemGray4), Color(UIColor.systemGray5)]
        }
        return emotion.gradient
    }
}

let stickerOptions: [(icon: String, label: String)] = [
    ("heart.fill", "Heart"),
    ("sun.max.fill", "Sun"),
    ("moon.stars.fill", "Night Sky"),
    ("moon.zzz.fill", "Sleepy"),
    ("cloud.rain.fill", "Rainy Day"),
    ("cloud.bolt.fill", "Storm"),
    ("snowflake", "Winter"),
    ("flame.fill", "Flame"),
    ("leaf.fill", "Leaf"),
    ("tree.fill", "Tree"),
    ("camera.macro", "Macro"),
    ("rainbow", "Rainbow"),
    ("sparkles", "Sparkles"),
    ("star.fill", "Star"),
    ("face.smiling.fill", "Smile"),
    ("gift.fill", "Gift"),
    ("cup.and.saucer.fill", "Coffee"),
    ("mug.fill", "Mug"),
    ("fork.knife", "Food"),
    ("pawprint.fill", "Paws"),
    ("airplane", "Travel"),
    ("car.fill", "Road Trip"),
    ("figure.walk", "Walk"),
    ("figure.run", "Run"),
    ("figure.hiking", "Hiking"),
    ("figure.yoga", "Yoga"),
    ("figure.dance", "Dance"),
    ("dumbbell.fill", "Gym"),
    ("soccerball", "Football"),
    ("basketball.fill", "Basketball"),
    ("tennis.racket", "Tennis"),
    ("mountain.2.fill", "Mountains"),
    ("water.waves", "Ocean"),
    ("house.fill", "Home"),
    ("music.note", "Music"),
    ("book.fill", "Book"),
    ("camera.fill", "Camera"),
    ("photo.fill", "Photo"),
    ("paintbrush.fill", "Art"),
    ("theatermasks.fill", "Drama"),
    ("gamecontroller.fill", "Games"),
    ("crown.fill", "Crown"),
    ("trophy.fill", "Trophy"),
    ("medal.fill", "Medal"),
    ("map.fill", "Map"),
    ("lightbulb.fill", "Idea"),
    ("wand.and.stars", "Magic"),
    ("bolt.fill", "Energy"),
    ("atom", "Science"),
    ("hands.clap.fill", "Clap"),
]
