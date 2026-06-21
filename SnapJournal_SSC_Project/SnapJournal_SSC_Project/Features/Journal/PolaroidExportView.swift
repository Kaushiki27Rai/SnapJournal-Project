//
//  PolaroidExportView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct PolaroidExportView: View {
    let moment: Moment

    private let cardWidth: CGFloat = 280
    private let photoHeight: CGFloat = 260
    private let stripHeight: CGFloat = 92
    private let cornerRadius: CGFloat = 4
    private let imagePadding: CGFloat = 16

    private var cardHeight: CGFloat { photoHeight + stripHeight }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let emotion = moment.emotion {
                    LinearGradient(colors: emotion.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    Color.white
                }
                Image(uiImage: moment.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth - imagePadding * 2, height: photoHeight - imagePadding * 2)
                    .clipped()
                    .padding(imagePadding)
            }
            .frame(width: cardWidth, height: photoHeight)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                if !moment.publicReflection.isEmpty {
                    Text(moment.publicReflection)
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(moment.date, style: .date)
                    .font(.system(size: 9, weight: .light))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(width: cardWidth, height: stripHeight, alignment: .topLeading)
            .background(
                Group {
                    if let emotion = moment.emotion {
                        LinearGradient(colors: emotion.gradient,
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white
                    }
                }
            )
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    PolaroidExportView(moment: Moment(
        image: UIImage(systemName: "photo")!,
        date: Date(),
        emotion: emotionList[0],
        publicReflection: "A lovely memory.",
        privateBackNote: nil
    ))
}
