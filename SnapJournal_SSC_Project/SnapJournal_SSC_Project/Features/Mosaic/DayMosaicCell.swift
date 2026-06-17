//
//  DayMosaicCell.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct DayMosaicCell: View {

    let date: Date
    let moments: [Moment]
    let onTap: (Moment) -> Void
    let onTapGroup: ([Moment], CGRect, CGSize) -> Void

    private let calendar = Calendar.current
    private var isToday: Bool { calendar.isDateInToday(date) }
    private var dayNumber: String { "\(calendar.component(.day, from: date))" }

    @State private var isPressed = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let size = (w.isFinite && w > 0) ? w : 1

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemFill))

                if w.isFinite && w > 0 {
                    mosaicFill(size: size).clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Text(dayNumber)
                    .font(.system(size: 12, weight: isToday ? .bold : .medium))
                    .foregroundStyle(moments.isEmpty ? Color(UIColor.tertiaryLabel) : .white)
                    .shadow(color: moments.isEmpty ? .clear : .black.opacity(0.35), radius: 2, x: 0, y: 1)
                    .padding(5).allowsHitTesting(false)

                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(UIColor.label).opacity(0.75), lineWidth: 1.5)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isPressed)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in guard !moments.isEmpty else { return }; if !isPressed { isPressed = true } }
                    .onEnded { _ in
                        guard !moments.isEmpty else { return }
                        isPressed = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if moments.count == 1, let first = moments.first {
                            onTap(first)
                        } else if moments.count > 1 {
                            onTapGroup(moments,
                                       geo.frame(in: .global),
                                       currentScreenSize())
                        }
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(moments.count > 1
                ? "Double tap to choose one moment from this day."
                : "Double tap to open this moment.")
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func mosaicFill(size: CGFloat) -> some View {
        switch moments.count {
        case 0: Color.clear
        case 1: grad(moments[0])
        case 2:
            ZStack {
                grad(moments[1]).clipShape(BottomRightTriangle())
                grad(moments[0]).clipShape(TopLeftTriangle())
            }
        case 3:
            ZStack {
                grad(moments[2]).clipShape(BottomWedge())
                grad(moments[1]).clipShape(RightWedge())
                grad(moments[0]).clipShape(TopWedge())
            }
        default:
            HStack(spacing: 0) {
                VStack(spacing: 0) { grad(moments[0]); grad(moments[2]) }
                VStack(spacing: 0) {
                    grad(moments[1])
                    grad(moments.count > 3 ? moments[3] : moments[2])
                }
            }
        }
    }

    private func grad(_ m: Moment) -> some View {
        LinearGradient(
            colors: m.emotion?.gradient ?? [Color(UIColor.systemGray4), Color(UIColor.systemGray5)],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var accessibilityLabel: String {
        moments.isEmpty    ? "Day \(dayNumber), no moments" :
        moments.count == 1 ? "Day \(dayNumber), one moment" :
                             "Day \(dayNumber), \(moments.count) moments"
    }
}

#Preview {
    DayMosaicCell(date: Date(), moments: [], onTap: { _ in }, onTapGroup: { _, _, _ in })
        .frame(width: 60, height: 60)
        .padding()
}
