//
//  PolaroidPageCard.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import LocalAuthentication

struct PolaroidPageCard: View {
    let moment: Moment
    @Environment(MomentStore.self) private var store
    @State private var isFlipped = false
    @State private var flipDegrees = 0.0
    @State private var privateNote: String
    @State private var showAuthFailAlert = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var zoomOffset: CGSize = .zero
    @State private var lastZoomOffset: CGSize = .zero

    init(moment: Moment) {
        self.moment = moment
        _privateNote = State(initialValue: moment.privateBackNote ?? "")
    }

    var body: some View {
        GeometryReader { geo in
            let availableWidth = max(geo.size.width - 48, 220.0)
            let cw = min(availableWidth, 320.0)
            let ch = cw * 1.42
            VStack(spacing: 16) {
                Spacer()
                VStack(spacing: 14) {
                    ZStack {
                        frontFace(cw, ch).rotation3DEffect(.degrees(flipDegrees), axis: (0,1,0), perspective: 0.4).opacity(isFlipped ? 0 : 1)
                        backFace(cw, ch).rotation3DEffect(.degrees(flipDegrees - 180), axis: (0,1,0), perspective: 0.4).opacity(isFlipped ? 1 : 0)
                    }
                    .frame(width: cw, height: ch)
                    .overlay(HStack(spacing: 0) {
                        Color.clear.frame(width: cw * 0.25).contentShape(Rectangle()).onTapGesture { authenticateAndFlip() }
                        Spacer()
                        Color.clear.frame(width: cw * 0.25).contentShape(Rectangle()).onTapGesture { authenticateAndFlip() }
                    })
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left.and.right").font(.system(size: 11))
                        Text(isFlipped ? "Tap either side of the polaroid to return" : "Tap either side of the polaroid to flip").font(.system(size: 12))
                    }
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .animation(.easeInOut(duration: 0.2), value: isFlipped)
                }
                .scaleEffect(zoomScale).offset(zoomOffset)
                .gesture(MagnifyGesture().onChanged { value in zoomScale = min(max(lastZoomScale * value.magnification, 1.0), 4.0) }
                    .onEnded { _ in lastZoomScale = zoomScale; if zoomScale < 1.05 { resetZoom() } }
                    .simultaneously(with: DragGesture().onChanged { value in
                        guard zoomScale > 1.05 else { return }
                        zoomOffset = CGSize(width: lastZoomOffset.width + value.translation.width,
                                            height: lastZoomOffset.height + value.translation.height)
                    }.onEnded { _ in lastZoomOffset = zoomOffset }))
                .onTapGesture(count: 2) { resetZoom() }
                Spacer()
            }.frame(maxWidth: .infinity)
        }
        .onDisappear {
            let t = privateNote.trimmingCharacters(in: .whitespacesAndNewlines)
            store.updatePrivateNote(id: moment.id, note: t.isEmpty ? nil : t)
        }
        .alert("Authentication Required", isPresented: $showAuthFailAlert) { Button("OK", role: .cancel) {} }
        message: { Text("You need to verify your identity to view the private note.") }
    }

    private func resetZoom() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            zoomScale = 1.0; zoomOffset = .zero; lastZoomScale = 1.0; lastZoomOffset = .zero
        }
    }

    private func frontFace(_ w: CGFloat, _ h: CGFloat) -> some View {
        let ph = h * 0.78; let ip: CGFloat = 12
        return VStack(spacing: 0) {
            ZStack {
                if let e = moment.emotion { LinearGradient(colors: e.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { Color(UIColor.systemGray5) }
                Image(uiImage: moment.image).resizable().scaledToFill().frame(width: w - ip*2, height: ph - ip*2).clipped().padding(ip)
            }.frame(width: w, height: ph).clipped()
            VStack(alignment: .leading, spacing: 5) {
                if !moment.publicReflection.isEmpty {
                    Text(moment.publicReflection).font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundStyle(Color(UIColor.label)).lineLimit(3)
                }
                Text(moment.date, style: .date).font(.system(size: 10, weight: .light)).foregroundStyle(Color(UIColor.secondaryLabel))
            }
            .padding(.horizontal, 14).padding(.vertical, 10).frame(width: w, alignment: .leading).frame(maxHeight: .infinity)
            .background(Group {
                if let e = moment.emotion { LinearGradient(colors: e.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { Color(UIColor.systemBackground) }
            })
        }
        .frame(width: w, height: h).background(Color(UIColor.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
    }

    private func backFace(_ w: CGFloat, _ h: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Private").font(.system(size: 10, weight: .medium))
                        .foregroundStyle(moment.emotion?.gradient.first ?? .secondary).kerning(1.5).textCase(.uppercase)
                    Spacer()
                    Image(systemName: "lock.fill").font(.system(size: 10)).foregroundStyle(moment.emotion?.gradient.first ?? .secondary)
                }
                Text("Would you like to share more...?").font(.system(size: 13, weight: .light, design: .serif)).italic()
                    .foregroundStyle(Color(UIColor.label).opacity(0.65))
            }
            .padding(.horizontal, 18).padding(.top, 20).padding(.bottom, 12)
            Rectangle().fill(Color(UIColor.separator)).frame(height: 0.5).padding(.horizontal, 18)
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    let s: CGFloat = 28
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        ForEach(0..<Int(geo.size.height / s), id: \.self) { i in
                            Rectangle().fill(Color.black.opacity(0.06)).frame(height: 0.5).offset(y: CGFloat(i) * s + 44)
                        }
                    }
                }.allowsHitTesting(false)
                TextEditor(text: $privateNote).font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color(UIColor.label)).scrollContentBackground(.hidden).background(Color.clear)
                    .padding(.horizontal, 12).padding(.top, 6)
            }.frame(maxHeight: .infinity)
        }
        .frame(width: w, height: h).background(Color.linedPaper)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
    }

    private func authenticateAndFlip() {
        guard zoomScale < 1.05 else { return }
        if isFlipped { flip(); return }
        let hasContent = !privateNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard hasContent else { flip(); return }
        let context = LAContext(); var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to view your private note.") { success, _ in
                DispatchQueue.main.async { if success { flip() } else { showAuthFailAlert = true } }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to view your private note.") { success, _ in
                DispatchQueue.main.async { if success { flip() } else { showAuthFailAlert = true } }
            }
        } else { flip() }
    }

    private func flip() {
        let target = isFlipped ? 0.0 : 180.0
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) { flipDegrees = target }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { isFlipped.toggle() }
    }
}

#Preview {
    PolaroidPageCard(moment: Moment(image: UIImage(systemName: "photo")!, date: Date(), emotion: emotionList[0], publicReflection: "A lovely memory.", privateBackNote: nil))
        .environment(MomentStore())
}
