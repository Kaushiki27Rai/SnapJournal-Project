//
//  PolaroidPagerView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import Photos

struct PolaroidPagerView: View {
    let album: Album
    let initialIndex: Int
    let onDismiss: () -> Void

    @Environment(MomentStore.self) private var store
    @Environment(AlbumStore.self) private var albumStore
    @State private var currentIndex: Int
    @State private var showDeleteAlert = false
    @State private var showSaveSuccess = false

    private var moments: [Moment] {
        albumStore.moments(for: album, in: store)
    }

    init(album: Album, initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.album = album
        self.initialIndex = initialIndex
        self.onDismiss = onDismiss
        _currentIndex = State(initialValue: initialIndex)
    }

    private var currentMoment: Moment? {
        guard currentIndex >= 0, currentIndex < moments.count else { return nil }
        return moments[currentIndex]
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            if let moment = currentMoment, let emotion = moment.emotion {
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
                    if !moments.isEmpty {
                        Text("\(currentIndex + 1) / \(moments.count)").font(.system(size: 13))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                    Spacer()
                    if let moment = currentMoment {
                        Menu {
                            Button { saveToPhotos(moment: moment) } label: { Label("Save to Photos", systemImage: "square.and.arrow.down") }
                            Divider()
                            Button(role: .destructive) { showDeleteAlert = true } label: { Label("Remove from album", systemImage: "minus.circle") }
                        } label: {
                            Image(systemName: "ellipsis.circle").font(.system(size: 22)).foregroundStyle(Color(UIColor.label))
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 8)

                if moments.isEmpty {
                    Spacer()
                    Text("No moments in this album.")
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    Spacer()
                } else {
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

    private func saveToPhotos(moment: Moment) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else { return }
                let exportView = PolaroidExportView(moment: moment)
                let renderer = ImageRenderer(content: exportView)
                renderer.scale = 3.0
                renderer.proposedSize = .init(width: 280, height: 352)
                guard let rendered = renderer.uiImage,
                      let _ = rendered.cgImage else { return }
                UIImageWriteToSavedPhotosAlbum(rendered, nil, nil, nil)
                withAnimation(.spring()) { showSaveSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showSaveSuccess = false } }
            }
        }
    }

    private func removeFromAlbum() {
        guard let moment = currentMoment else { return }
        let id = moment.id
        let newCount = moments.count - 1
        if currentIndex >= newCount, currentIndex > 0 {
            currentIndex -= 1
        }
        albumStore.removeMoment(momentID: id, from: album.id)
        if newCount <= 0 { onDismiss() }
    }
}

#Preview {
    PolaroidPagerView(album: Album(name: "Summer Trips", stickerIcon: "sun.max.fill"), initialIndex: 0, onDismiss: {})
        .environment(MomentStore())
        .environment(AlbumStore())
}
