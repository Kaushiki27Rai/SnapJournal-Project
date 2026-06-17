//
//  AlbumStore.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import Foundation
import Observation

@Observable
final class AlbumStore {

    private(set) var albums: [Album] = []

    private let key = "snapjournal.albums"

    init() { load() }

    func createAlbum(name: String, stickerIcon: String) {
        albums.append(Album(name: name, stickerIcon: stickerIcon))
        save()
    }

    func deleteAlbum(id: UUID) {
        albums.removeAll { $0.id == id }
        save()
    }

    func addMoment(momentID: UUID, to albumID: UUID) {
        guard let i = albums.firstIndex(where: { $0.id == albumID }) else { return }
        guard !albums[i].momentIDs.contains(momentID) else { return }
        albums[i].momentIDs.append(momentID)
        save()
    }

    func removeMoment(momentID: UUID, from albumID: UUID) {
        guard let i = albums.firstIndex(where: { $0.id == albumID }) else { return }
        albums[i].momentIDs.removeAll { $0 == momentID }
        save()
    }

    func moments(for album: Album, in store: MomentStore) -> [Moment] {
        album.momentIDs.compactMap { id in store.moments.first { $0.id == id } }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(albums) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Album].self, from: data)
        else { return }
        albums = decoded
    }
}
