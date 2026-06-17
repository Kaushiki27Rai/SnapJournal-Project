//
//  MosaicInfoSheet.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct MosaicInfoSheet: View {

    @Environment(\.dismiss) private var dismiss

    private struct InfoRow: Identifiable {
        let id = UUID()
        let icon: String
        let color: Color
        let title: String
        let body: String
    }

    private let rows: [InfoRow] = [
        InfoRow(
            icon: "square.grid.3x3.fill",
            color: .mosaicBlue,
            title: "Your month at a glance",
            body: "Each day tile is painted in the colours of the emotions you captured — so you can feel a whole month in a single look."
        ),
        InfoRow(
            icon: "hand.tap.fill",
            color: .mosaicPurple,
            title: "Tap a day to explore",
            body: "Tap any coloured tile to open the moments from that day. If there are several, a small picker lets you choose which one to open."
        ),
        InfoRow(
            icon: "chart.bar.fill",
            color: .mosaicOrange,
            title: "Spot your patterns",
            body: "Over time the mosaic shows you how you actually felt — not just what you did. Weeks of calm, a burst of energy, a quiet stretch of grey."
        ),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                Capsule()
                    .fill(Color(UIColor.tertiaryLabel))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 28)

                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.mosaicOrange, .mosaicPurple, .mosaicBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)

                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { col in
                            VStack(spacing: 6) {
                                ForEach(0..<4, id: \.self) { row in
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(
                                            [[0.55,0.30,0.45,0.20],
                                             [0.25,0.50,0.15,0.40],
                                             [0.40,0.20,0.55,0.30],
                                             [0.15,0.45,0.25,0.50]][col][row]
                                        ))
                                        .frame(width: 28, height: 28)
                                }
                            }
                        }
                    }
                    .opacity(0.6)

                    VStack(spacing: 8) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        Text("Mood Mosaic")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                Text("A living picture of how your month felt.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 28)

                sectionHeader("How it works")

                VStack(spacing: 0) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(row.color.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: row.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(row.color)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(UIColor.label))
                                Text(row.body)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        if row.id != rows.last?.id {
                            Divider().padding(.leading, 78)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .tracking(0.8)
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
    }
}

#Preview {
    MosaicInfoSheet()
}
