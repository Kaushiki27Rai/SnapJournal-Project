//
//  AddMomentsToAlbumView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct AddMomentsToAlbumView: View {
    let album: Album
    @Environment(MomentStore.self) private var store
    @Environment(AlbumStore.self) private var albumStore
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.flexible(), spacing: 3), GridItem(.flexible(), spacing: 3)]
    private func isAssigned(_ m: Moment) -> Bool { album.momentIDs.contains(m.id) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                if store.moments.isEmpty {
                    VStack(spacing: 12) { Spacer(); Text("No moments in your library yet.").foregroundStyle(.secondary); Spacer() }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 3) {
                            ForEach(store.moments) { moment in
                                ZStack(alignment: .topTrailing) {
                                    MomentCard(moment: moment).opacity(isAssigned(moment) ? 0.6 : 1.0)
                                        .onTapGesture {
                                            isAssigned(moment)
                                            ? albumStore.removeMoment(momentID: moment.id, from: album.id)
                                            : albumStore.addMoment(momentID: moment.id, to: album.id)
                                        }
                                    if isAssigned(moment) {
                                        Image(systemName: "checkmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white)
                                            .background(Circle().fill(Color.green)).padding(6)
                                    }
                                }
                            }
                        }.padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Add to \(album.name)").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

#Preview {
    NavigationStack {
        AddMomentsToAlbumView(album: Album(name: "Summer Trips", stickerIcon: "sun.max.fill"))
            .environment(MomentStore())
            .environment(AlbumStore())
    }
}
