//
//  PolaroidPagerView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import Photos

struct PolaroidPagerView: View {
    let moments: [Moment]
    let initialIndex: Int
    let album: Album
    let onDismiss: () -> Void

    @Environment(MomentStore.self) private var store
    @Environment(AlbumStore.self) private var albumStore
    @State private var currentIndex: Int
    @State private var showDeleteAlert = false
    @State private var showSaveSuccess = false

    init(moments: [Moment], initialIndex: Int, album: Album, onDismiss: @escaping () -> Void) {
        self.moments = moments; self.initialIndex = initialIndex
        self.album = album; self.onDismiss = onDismiss
        _currentIndex = State(initialValue: initialIndex)
    }

    private var currentMoment: Moment { moments[currentIndex] }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            if let emotion = currentMoment.emotion {
                LinearGradient(colors: [emotion.gradient.first?.opacity(0.12) ?? .clear, .clear],
                               startPoint: .top, endPoint: .center).ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.35), value: currentIndex)
            }
            VStack(spacing: 0) {
                HStack {
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 26))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                    Spacer()
                    Text("\(currentIndex + 1) / \(moments.count)").font(.system(size: 13))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    Spacer()
                    Menu {
                        Button { saveToPhotos() } label: { Label("Save to Photos", systemImage: "square.and.arrow.down") }
                        Divider()
                        Button(role: .destructive) { showDeleteAlert = true } label: { Label("Remove from album", systemImage: "minus.circle") }
                    } label: {
                        Image(systemName: "ellipsis.circle").font(.system(size: 22)).foregroundStyle(Color(UIColor.label))
                    }
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 8)

                TabView(selection: $currentIndex) {
                    ForEach(Array(moments.enumerated()), id: \.element.id) { idx, moment in
                        PolaroidPageCard(moment: moment).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if moments.count > 1 {
                    HStack(spacing: 5) {
                        ForEach(moments.indices, id: \.self) { i in
                            Circle()
                                .fill(i == currentIndex ? Color(UIColor.label) : Color(UIColor.systemGray4))
                                .frame(width: i == currentIndex ? 7 : 5, height: i == currentIndex ? 7 : 5)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                        }
                    }.padding(.bottom, 20)
                }
            }
            if showSaveSuccess {
                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
                        Text("Saved to Photos").font(.system(size: 14, weight: .medium)).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(Capsule().fill(Color.black.opacity(0.75)))
                    .padding(.bottom, 60).transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .alert("Remove from \(album.name)?", isPresented: $showDeleteAlert) {
            Button("Remove", role: .destructive) { removeFromAlbum() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func saveToPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else { return }
                UIImageWriteToSavedPhotosAlbum(currentMoment.image, nil, nil, nil)
                withAnimation(.spring()) { showSaveSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showSaveSuccess = false } }
            }
        }
    }

    private func removeFromAlbum() {
        let id = currentMoment.id
        if currentIndex >= moments.count - 1, currentIndex > 0 { currentIndex -= 1 }
        albumStore.removeMoment(momentID: id, from: album.id)
        if moments.count <= 1 { onDismiss() }
    }
}

#Preview {
    PolaroidPagerView(moments: [], initialIndex: 0, album: Album(name: "Summer Trips", stickerIcon: "sun.max.fill"), onDismiss: {})
        .environment(MomentStore())
        .environment(AlbumStore())
}
