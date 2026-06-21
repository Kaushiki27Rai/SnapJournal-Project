//
//  MomentCard.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct MomentCard: View {
    let moment: Moment

    var body: some View {
        GeometryReader { geo in
            let size = max(geo.size.width, 1)

            VStack(spacing: 0) {
                ZStack {
                    if let emotion = moment.emotion {
                        LinearGradient(colors: emotion.gradient,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    } else {
                        Color(UIColor.systemGray5)
                    }

                    Image(uiImage: moment.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size - 16, height: size * 0.72 - 16)
                        .clipped()
                        .padding(8)

                    if moment.hasPrivateNote {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(.white)
                                    .padding(5)
                                    .background(Color.black.opacity(0.35))
                                    .clipShape(Circle())
                                    .padding(6)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(width: size, height: size * 0.72)
                .clipped()

                VStack(alignment: .leading, spacing: 2) {
                    if !moment.publicReflection.isEmpty {
                        Text(moment.publicReflection)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(Color(UIColor.label))
                            .lineLimit(1)
                    }
                    Text(moment.date, style: .date)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(width: size, height: size * 0.28, alignment: .leading)
                .background(
                    Group {
                        if let grad = moment.emotion?.gradient {
                            LinearGradient(colors: grad,
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        } else {
                            LinearGradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray5)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        }
                    }
                )
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(moment.emotion?.name ?? "Unknown") moment. \(moment.publicReflection)\(moment.hasPrivateNote ? ". Has private note." : "")"
        )
    }
}

#Preview {
    MomentCard(moment: Moment(image: UIImage(systemName: "photo")!, date: Date(), emotion: emotionList[0], publicReflection: "A lovely memory.", privateBackNote: nil))
        .frame(width: 200)
}
