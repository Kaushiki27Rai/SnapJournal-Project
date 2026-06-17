//
//  AlbumDetailView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @Environment(MomentStore.self) private var store
    @Environment(AlbumStore.self) private var albumStore
    @State private var showAddMoments = false
    @State private var selectedIndex: Int?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    private var moments: [Moment] { albumStore.moments(for: album, in: store) }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            if moments.isEmpty { emptyState }
            else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(moments.enumerated()), id: \.element.id) { idx, moment in
                            MomentCard(moment: moment).contentShape(Rectangle())
                                .onTapGesture { selectedIndex = idx }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        albumStore.removeMoment(momentID: moment.id, from: album.id)
                                    } label: { Label("Remove from binder", systemImage: "minus.circle") }
                                }
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 80)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showAddMoments = true } label: {
                        Image(systemName: "plus").font(.system(size: 20)).foregroundStyle(Color(UIColor.label))
                            .frame(width: 52, height: 52)
                            .background(LiquidGlassBackground(style: .systemUltraThinMaterial))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(
                                LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 5)
                    }
                    .padding(.trailing, 24).padding(.bottom, 32)
                }
            }
        }
        .navigationTitle(album.name).navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddMoments) { AddMomentsToAlbumView(album: album) }
        .fullScreenCover(item: Binding(
            get: { selectedIndex.map { PagerIndex(value: $0) } },
            set: { selectedIndex = $0?.value }
        )) { pagerIndex in
            PolaroidPagerView(moments: moments, initialIndex: pagerIndex.value,
                              album: album, onDismiss: { selectedIndex = nil })
                .environment(store).environment(albumStore)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: album.stickerIcon).font(.system(size: 44)).foregroundStyle(Color(UIColor.systemGray3))
            Text("This album is empty.").font(.system(size: 16, weight: .light, design: .serif)).italic()
                .foregroundStyle(Color(UIColor.secondaryLabel))
            Button("Add moments") { showAddMoments = true }.font(.system(size: 14)).foregroundStyle(Color(UIColor.systemBlue))
            Spacer(); Spacer()
        }
    }
}

struct PagerIndex: Identifiable { let value: Int; var id: Int { value } }

#Preview {
    NavigationStack {
        AlbumDetailView(album: Album(name: "Summer Trips", stickerIcon: "sun.max.fill"))
            .environment(MomentStore())
            .environment(AlbumStore())
    }
}
