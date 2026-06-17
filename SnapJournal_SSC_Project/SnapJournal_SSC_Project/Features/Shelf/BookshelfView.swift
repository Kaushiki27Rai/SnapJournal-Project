//
//  BookshelfView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct BookshelfView: View {

    @Environment(MomentStore.self) private var store
    @Environment(AlbumStore.self) private var albumStore

    @State private var showCreateSheet = false
    @State private var searchText = ""
    @State private var albumToDelete: Album?
    @State private var showDeleteConfirm = false

    private var filteredAlbums: [Album] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return albumStore.albums }
        return albumStore.albums.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.shelfBackground.ignoresSafeArea()

                if albumStore.albums.isEmpty {
                    emptyState
                } else {
                    if filteredAlbums.isEmpty && !searchText.isEmpty {
                        noResultsState
                    } else {
                        albumGrid
                    }
                }

                newAlbumButton
            }
            .navigationTitle("Memory Shelf")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search albums...")
            .sheet(isPresented: $showCreateSheet) { CreateAlbumView() }
            .alert(
                albumToDelete.map { "Delete \"\($0.name)\"?" } ?? "Delete Album?",
                isPresented: $showDeleteConfirm
            ) {
                Button("Delete", role: .destructive) {
                    if let album = albumToDelete { albumStore.deleteAlbum(id: album.id) }
                    albumToDelete = nil
                }
                Button("Cancel", role: .cancel) { albumToDelete = nil }
            } message: {
                Text("This will remove the album. Your moments won't be deleted.")
            }
        }
    }

    private var albumGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                ForEach(filteredAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        BinderCard(album: album, moments: albumStore.moments(for: album, in: store))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            albumToDelete = album; showDeleteConfirm = true
                        } label: {
                            Label("Delete Album", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 100)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "books.vertical").font(.system(size: 48))
                .foregroundStyle(Color(UIColor.systemGray3))
            Text("No albums yet").font(.system(size: 17)).foregroundStyle(Color(UIColor.label))
            Text("Create one to organise your moments.").font(.system(size: 14)).foregroundStyle(.secondary)
            Spacer(); Spacer()
        }
    }

    private var noResultsState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "magnifyingglass").font(.system(size: 40))
                .foregroundStyle(Color(UIColor.systemGray3))
            Text("No albums matching \"\(searchText)\"").font(.system(size: 15))
                .foregroundStyle(Color(UIColor.secondaryLabel))
            Spacer()
        }
    }

    private var newAlbumButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button { showCreateSheet = true } label: {
                    Image(systemName: "plus").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(UIColor.label))
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .background(LiquidGlassBackground(style: .systemUltraThinMaterial))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(
                            LinearGradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.1)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 6)
                }
                .padding(.trailing, 24).padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    BookshelfView()
        .environment(MomentStore())
        .environment(AlbumStore())
}
