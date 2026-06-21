//
//  MomentStore.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import Observation

private struct MomentDTO: Codable {
    let id: UUID
    let emotionName: String?
    let publicReflection: String
    let privateBackNote: String?
    let date: Date
}

@Observable
final class MomentStore {

    private(set) var moments: [Moment] = []
    var justSaved = false

    private let metaKey = "snapjournal.moments.v2"
    private let legacyKey = "snapjournal.moments"

    private let imageDir: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SnapJournalImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    init() {
        migrateLegacyIfNeeded()
        load()
    }

    func addMoment(_ moment: Moment) {
        saveImage(moment.image, id: moment.id)
        moments.insert(moment, at: 0)
        saveMetadata()
    }

    func deleteMoment(id: UUID) {
        deleteImage(id: id)
        moments.removeAll { $0.id == id }
        saveMetadata()
    }

    func updatePrivateNote(id: UUID, note: String?) {
        guard let i = moments.firstIndex(where: { $0.id == id }) else { return }
        moments[i].privateBackNote = note
        saveMetadata()
    }

    private func imagePath(for id: UUID) -> URL {
        imageDir.appendingPathComponent("\(id.uuidString).jpg")
    }

    private func saveImage(_ image: UIImage, id: UUID) {
        guard let cgImage = image.cgImage else { return }
        let oriented = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        guard let data = oriented.jpegData(compressionQuality: 0.82) else { return }
        try? data.write(to: imagePath(for: id), options: .atomic)
    }

    private func loadImage(id: UUID) -> UIImage? {
        let url = imagePath(for: id)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              !data.isEmpty,
              let image = UIImage(data: data),
              let _ = image.cgImage
        else { return nil }
        return image
    }

    private func deleteImage(id: UUID) {
        try? FileManager.default.removeItem(at: imagePath(for: id))
    }

    private func saveMetadata() {
        let dtos = moments.map {
            MomentDTO(id: $0.id, emotionName: $0.emotion?.name,
                      publicReflection: $0.publicReflection,
                      privateBackNote: $0.privateBackNote, date: $0.date)
        }
        if let encoded = try? JSONEncoder().encode(dtos) {
            UserDefaults.standard.set(encoded, forKey: metaKey)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: metaKey),
            let dtos = try? JSONDecoder().decode([MomentDTO].self, from: data)
        else { return }

        moments = dtos.compactMap { dto in
            guard let image = loadImage(id: dto.id) else { return nil }
            let emotion = dto.emotionName.flatMap { name in emotionList.first { $0.name == name } }
            var m = Moment(image: image, date: dto.date, emotion: emotion,
                           publicReflection: dto.publicReflection,
                           privateBackNote: dto.privateBackNote)
            m.id = dto.id
            return m
        }
    }

    private func migrateLegacyIfNeeded() {
        guard let data = UserDefaults.standard.data(forKey: legacyKey) else { return }

        struct LegacyDTO: Codable {
            let id: UUID; let imageData: Data; let emotionName: String?
            let publicReflection: String; let privateBackNote: String?; let date: Date
        }

        guard let legacy = try? JSONDecoder().decode([LegacyDTO].self, from: data) else {
            UserDefaults.standard.removeObject(forKey: legacyKey); return
        }
        for dto in legacy {
            let path = imagePath(for: dto.id)
            if !FileManager.default.fileExists(atPath: path.path) {
                try? dto.imageData.write(to: path, options: .atomic)
            }
        }
        let v2 = legacy.map {
            MomentDTO(id: $0.id, emotionName: $0.emotionName,
                      publicReflection: $0.publicReflection,
                      privateBackNote: $0.privateBackNote, date: $0.date)
        }
        if let encoded = try? JSONEncoder().encode(v2) {
            UserDefaults.standard.set(encoded, forKey: metaKey)
        }
        UserDefaults.standard.removeObject(forKey: legacyKey)
    }
}
