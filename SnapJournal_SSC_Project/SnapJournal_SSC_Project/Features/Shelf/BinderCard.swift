//
//  BinderCard.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct BinderCard: View {
    let album: Album
    let moments: [Moment]

    private var dominantEmotion: Emotion? { album.dominantEmotion(from: moments) }

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if let emotion = dominantEmotion {
                    LinearGradient(colors: emotion.gradient, startPoint: .top, endPoint: .bottom)
                } else {
                    LinearGradient(colors: [Color(UIColor.systemGray4), Color(UIColor.systemGray5)],
                                   startPoint: .top, endPoint: .bottom)
                }
                Text(album.name).font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                    .rotationEffect(.degrees(-90)).lineLimit(1).frame(width: 80)
            }
            .frame(width: 22)

            ZStack {
                Color.binderCover
                VStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle().fill(Color.black.opacity(0.03)).frame(height: 0.5)
                    }
                }
                .padding(.horizontal, 6)
                VStack(spacing: 8) {
                    Image(systemName: album.stickerIcon).font(.system(size: 28))
                        .foregroundStyle(dominantEmotion?.gradient.first ?? Color(UIColor.systemGray3))
                    Text(album.name)
                        .font(.system(size: 13, weight: .regular, design: .serif)).italic()
                        .foregroundStyle(Color(UIColor.label).opacity(0.75))
                        .multilineTextAlignment(.center).lineLimit(2).padding(.horizontal, 8)
                    Text("\(moments.count) \(moments.count == 1 ? "moment" : "moments")")
                        .font(.system(size: 9, weight: .light)).foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 2, y: 4)
    }
}

#Preview {
    BinderCard(album: Album(name: "Summer Trips", stickerIcon: "sun.max.fill"), moments: [])
        .padding()
}
