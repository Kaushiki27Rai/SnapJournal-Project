//
//  MoodMosaicView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct MoodMosaicView: View {

    @Environment(MomentStore.self) private var store
    @Namespace private var heroNS
    @State private var heroMoment: Moment? = nil
    @State private var dayAnchor: DayPickerAnchor? = nil
    @State private var currentMonth = Date()
    @State private var showInfo = false

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        monthNavigation
                            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)

                        HStack(spacing: 0) {
                            ForEach(weekdayLabels) { l in
                                Text(l.text)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 16).padding(.bottom, 10)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(daysInMonth().enumerated()), id: \.offset) { _, date in
                                if let date {
                                    let ms = momentsOn(date)
                                    let cell = DayMosaicCell(
                                        date: date,
                                        moments: ms,
                                        onTap: { m in
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                                heroMoment = m
                                            }
                                        },
                                        onTapGroup: { moments, cellFrame, screenSize in
                                            let n = moments.count
                                            let h = Pop.cardH(n)
                                            let scrolls = n > Pop.maxRows

                                            let spaceBelow = screenSize.height - cellFrame.maxY
                                            let below = spaceBelow >= h + Pop.gap + 20

                                            let rawY = below
                                                ? cellFrame.maxY + Pop.gap
                                                : cellFrame.minY - h - Pop.gap
                                            let safeY = max(rawY, Pop.topBarH)

                                            let idealX = cellFrame.midX - Pop.width / 2
                                            let safeX = min(max(idealX, Pop.edge),
                                                             screenSize.width - Pop.width - Pop.edge)

                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                                dayAnchor = DayPickerAnchor(
                                                    date: date,
                                                    moments: moments,
                                                    cardX: safeX,
                                                    cardY: safeY,
                                                    cardH: h,
                                                    showBelow: below,
                                                    scrolls: scrolls
                                                )
                                            }
                                        }
                                    )
                                    if ms.count == 1, let solo = ms.first {
                                        cell.matchedGeometryEffect(
                                            id: solo.id, in: heroNS,
                                            isSource: heroMoment?.id != solo.id)
                                    } else { cell }
                                } else {
                                    Color.clear.aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .scrollDisabled(dayAnchor != nil || heroMoment != nil)

                if let m = heroMoment { heroOverlay(moment: m) }
                if let a = dayAnchor { anchoredPicker(anchor: a) }
            }
            .navigationTitle("Mood Mosaic")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 17))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                    .accessibilityLabel("About Mood Mosaic")
                }
            }
            .sheet(isPresented: $showInfo) {
                MosaicInfoSheet()
            }
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) { dayAnchor = nil }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left").font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.secondarySystemFill))
                    .clipShape(Circle())
            }
            Spacer()
            Text(currentMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(UIColor.label))
            Spacer()
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) { dayAnchor = nil }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right").font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.secondarySystemFill))
                    .clipShape(Circle())
            }
        }
    }

    @ViewBuilder
    private func heroOverlay(moment: Moment) -> some View {
        ZStack {
            Color.black.opacity(0.50).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { heroMoment = nil }
                }
            VStack(spacing: 0) {
                ZStack {
                    if let e = moment.emotion {
                        LinearGradient(colors: e.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else { Color(UIColor.systemGray5) }
                    Image(uiImage: moment.image).resizable().scaledToFill()
                        .frame(width: 236, height: 236).clipped().padding(12)
                }
                .frame(width: 268, height: 268).clipped()

                VStack(alignment: .leading, spacing: 4) {
                    if !moment.publicReflection.isEmpty {
                        Text(moment.publicReflection).font(.system(size: 13))
                            .foregroundStyle(Color(UIColor.label)).lineLimit(2)
                    }
                    Text(moment.date, style: .date).font(.system(size: 10))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                .padding(.horizontal, 14).padding(.vertical, 12).frame(width: 268, alignment: .leading)
                .background(Group {
                    if let g = moment.emotion?.gradient {
                        LinearGradient(colors: g, startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        LinearGradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray5)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                })
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.20), radius: 24, x: 0, y: 12)
            .matchedGeometryEffect(id: moment.id, in: heroNS, isSource: true)

            VStack {
                Spacer()
                Text("Tap outside to close").font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.50)).padding(.bottom, 36)
            }
            .allowsHitTesting(false)
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private func anchoredPicker(anchor: DayPickerAnchor) -> some View {

        Color.black.opacity(0.20)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) { dayAnchor = nil }
            }
            .transition(.opacity)

        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: anchor.cardY)
            HStack(alignment: .top, spacing: 0) {
                Spacer().frame(width: anchor.cardX)

                VStack(spacing: 0) {
                    pickerHeader(date: anchor.date)
                    Divider()
                    Spacer().frame(height: Pop.vPad)

                    if anchor.scrolls {
                        ScrollView(.vertical, showsIndicators: true) {
                            pickerRows(anchor: anchor)
                        }
                        .frame(height: CGFloat(Pop.maxRows) * Pop.rowH)
                    } else {
                        pickerRows(anchor: anchor)
                    }

                    Spacer().frame(height: Pop.vPad)
                }
                .frame(width: Pop.width, height: anchor.cardH)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 6)
                .contentShape(RoundedRectangle(cornerRadius: 14))
                .onTapGesture { }
                .transition(
                    .scale(scale: 0.88, anchor: anchor.showBelow ? .top : .bottom)
                    .combined(with: .opacity)
                )
                .zIndex(100)

                Spacer()
            }
            Spacer()
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func pickerHeader(date: Date) -> some View {
        HStack {
            Text(date, format: .dateTime.day().month(.wide))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(UIColor.label))
            Spacer()
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) { dayAnchor = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Pop.hPad)
        .frame(height: Pop.headerH)
    }

    @ViewBuilder
    private func pickerRows(anchor: DayPickerAnchor) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(anchor.moments.enumerated()), id: \.element.id) { idx, moment in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) { dayAnchor = nil }
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(150))
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { heroMoment = moment }
                    }
                } label: {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                colors: moment.emotion?.gradient ?? [Color(UIColor.systemGray4)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 30, height: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(moment.emotion?.name ?? "Moment")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(UIColor.label))
                            Text(moment.date, style: .time)
                                .font(.system(size: 11))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.horizontal, Pop.hPad)
                    .frame(maxWidth: .infinity)
                    .frame(height: Pop.rowH)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if idx < anchor.moments.count - 1 {
                    Divider().padding(.horizontal, Pop.hPad)
                }
            }
        }
    }

    private func daysInMonth() -> [Date?] {
        guard
            let interval = calendar.dateInterval(of: .month, for: currentMonth),
            let firstWeekday = calendar.dateComponents([.weekday], from: interval.start).weekday
        else { return [] }

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        var d = interval.start
        while d < interval.end {
            days.append(d)
            d = calendar.date(byAdding: .day, value: 1, to: d) ?? d
        }
        let rem = days.count % 7
        if rem != 0 { days += Array(repeating: nil, count: 7 - rem) }
        return days
    }

    private func momentsOn(_ date: Date) -> [Moment] {
        store.moments.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

enum Pop {
    static let width: CGFloat = 220
    static let rowH: CGFloat = 58
    static let headerH: CGFloat = 40
    static let maxRows: Int = 5
    static let vPad: CGFloat = 8
    static let hPad: CGFloat = 14
    static let gap: CGFloat = 8
    static let edge: CGFloat = 12

    @MainActor
    static var topBarH: CGFloat {
        let inset = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow?.safeAreaInsets.top ?? 50
        return inset + 44
    }

    static func cardH(_ n: Int) -> CGFloat {
        headerH + CGFloat(min(n, maxRows)) * rowH + vPad * 2
    }
}

struct DayPickerAnchor: Identifiable {
    let id = UUID()
    let date: Date
    let moments: [Moment]
    let cardX: CGFloat
    let cardY: CGFloat
    let cardH: CGFloat
    let showBelow: Bool
    let scrolls: Bool
}

private struct WeekdayLabel: Identifiable { let id: Int; let text: String }

private let weekdayLabels: [WeekdayLabel] = [
    .init(id: 0, text: "SUN"), .init(id: 1, text: "MON"), .init(id: 2, text: "TUE"),
    .init(id: 3, text: "WED"), .init(id: 4, text: "THU"), .init(id: 5, text: "FRI"),
    .init(id: 6, text: "SAT"),
]

@MainActor
func currentScreenSize() -> CGSize {
    UIApplication.shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.screen.bounds.size ?? CGSize(width: 393, height: 852)
}

#Preview {
    MoodMosaicView()
        .environment(MomentStore())
}
