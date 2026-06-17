//
//  CreateAlbumView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct CreateAlbumView: View {

    @Environment(AlbumStore.self) private var albumStore
    @Environment(\.dismiss) private var dismiss

    @State private var albumName = ""
    @State private var selectedSticker = stickerOptions[0].icon
    @FocusState private var nameFocused: Bool

    private let stickerColumns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.shelfBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        HStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Rectangle().fill(Color(UIColor.systemGray4)).frame(width: 16, height: 90)
                                ZStack {
                                    Color.binderCover
                                    VStack(spacing: 6) {
                                        Image(systemName: selectedSticker).font(.system(size: 22))
                                            .foregroundStyle(Color(UIColor.systemGray2))
                                        Text(albumName.isEmpty ? "Name" : albumName)
                                            .font(.system(size: 11, weight: .regular, design: .serif)).italic()
                                            .foregroundStyle(Color(UIColor.secondaryLabel)).lineLimit(1)
                                    }
                                }
                                .frame(width: 80, height: 90)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 1, y: 3)
                            Spacer()
                        }
                        .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Album Name").font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.7))
                                if albumName.isEmpty {
                                    Text("e.g. Summer 2025, Travels...")
                                        .font(.system(size: 15, weight: .light, design: .serif)).italic()
                                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                                        .padding(.horizontal, 14).allowsHitTesting(false)
                                }
                                TextField("", text: $albumName)
                                    .font(.system(size: 15, weight: .regular, design: .serif))
                                    .padding(.horizontal, 14).padding(.vertical, 12)
                                    .focused($nameFocused).onSubmit { nameFocused = false }
                            }
                            .frame(height: 48)
                        }
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cover Sticker").font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(UIColor.secondaryLabel)).padding(.horizontal, 24)
                            LazyVGrid(columns: stickerColumns, spacing: 10) {
                                ForEach(stickerOptions, id: \.icon) { option in
                                    Button {
                                        selectedSticker = option.icon; nameFocused = false
                                    } label: {
                                        Image(systemName: option.icon).font(.system(size: 20))
                                            .foregroundStyle(selectedSticker == option.icon
                                                ? Color(UIColor.label) : Color(UIColor.systemGray3))
                                            .frame(width: 44, height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedSticker == option.icon ? Color.white : Color.clear)
                                                    .shadow(color: selectedSticker == option.icon
                                                        ? .black.opacity(0.08) : .clear, radius: 4, x: 0, y: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        Spacer().frame(height: 120)
                    }
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color.shelfBackground.opacity(0),
                                 Color.shelfBackground],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 24)

                    Button {
                        let name = albumName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        albumStore.createAlbum(name: name, stickerIcon: selectedSticker)
                        dismiss()
                    } label: {
                        let isEmpty = albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        Text("Create Album").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(isEmpty
                                ? AnyShapeStyle(Color(UIColor.systemGray4))
                                : AnyShapeStyle(Color.albumAccent))
                            .clipShape(Capsule())
                    }
                    .disabled(albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 24).padding(.bottom, 32)
                    .background(Color.shelfBackground)
                }
            }
            .navigationTitle("New Album").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { nameFocused = false }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.albumAccent)
                }
            }
        }
    }
}

#Preview {
    CreateAlbumView()
        .environment(AlbumStore())
}
