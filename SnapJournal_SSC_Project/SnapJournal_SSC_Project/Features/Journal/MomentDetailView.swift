//
//  MomentDetailView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import Photos
import LocalAuthentication

struct MomentDetailView: View {
    let moment: Moment
    @Environment(MomentStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var isFlipped = false
    @State private var flipDegrees = 0.0
    @State private var privateNote: String
    @State private var showDeleteAlert = false
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""
    @State private var showAuthFailAlert = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var zoomOffset: CGSize = .zero
    @State private var lastZoomOffset: CGSize = .zero
    @FocusState private var privateNoteFocused: Bool

    init(moment: Moment) {
        self.moment = moment
        _privateNote = State(initialValue: moment.privateBackNote ?? "")
    }

    var body: some View {
        GeometryReader { geo in
            let availableWidth = max(geo.size.width - 48, 220.0)
            let cw = min(availableWidth, 340.0)
            let ch = cw * 1.42
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                if let emotion = moment.emotion {
                    LinearGradient(colors: [emotion.gradient.first?.opacity(0.10) ?? .clear, .clear],
                                   startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                }
                VStack(spacing: 20) {
                    Spacer()
                    VStack(spacing: 14) {
                        ZStack {
                            frontFace(width: cw, height: ch)
                                .rotation3DEffect(.degrees(flipDegrees), axis: (0,1,0), perspective: 0.4).opacity(isFlipped ? 0 : 1)
                            backFace(width: cw, height: ch)
                                .rotation3DEffect(.degrees(flipDegrees - 180), axis: (0,1,0), perspective: 0.4).opacity(isFlipped ? 1 : 0)
                        }
                        .frame(width: cw, height: ch).overlay(sideTapZones(cardWidth: cw))
                        flipHint
                    }
                    .scaleEffect(zoomScale).offset(zoomOffset)
                    .gesture(MagnifyGesture()
                        .onChanged { value in zoomScale = min(max(lastZoomScale * value.magnification, 1.0), 4.0) }
                        .onEnded { _ in lastZoomScale = zoomScale; if zoomScale < 1.05 { resetZoom() } }
                        .simultaneously(with: DragGesture()
                            .onChanged { value in
                                guard zoomScale > 1.05 else { return }
                                zoomOffset = CGSize(width: lastZoomOffset.width + value.translation.width,
                                                    height: lastZoomOffset.height + value.translation.height)
                            }
                            .onEnded { _ in lastZoomOffset = zoomOffset }))
                    .onTapGesture(count: 2) { resetZoom() }
                    Spacer()
                    actionButtons.padding(.horizontal, 32).padding(.bottom, 36)
                }.frame(maxWidth: .infinity)

                if showSaveSuccess {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
                            Text("Saved to Photos").font(.system(size: 14, weight: .medium)).foregroundStyle(.white)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Capsule().fill(Color.black.opacity(0.75)))
                        .padding(.bottom, 50).transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .navigationTitle("Your Moment").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { saveToPhotos() } label: { Label("Save to Photos", systemImage: "square.and.arrow.down") }
                    Divider()
                    Button(role: .destructive) { showDeleteAlert = true } label: { Label("Delete Moment", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle").font(.system(size: 17)).foregroundStyle(Color(UIColor.label))
                }
            }
        }
        .alert("Delete this moment?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { deleteMoment() }; Button("Cancel", role: .cancel) {}
        } message: { Text("This can't be undone. Your memory will be removed from all albums too.") }
        .alert("Couldn't save", isPresented: $showSaveError) { Button("OK", role: .cancel) {} } message: { Text(saveErrorMessage) }
        .alert("Authentication Required", isPresented: $showAuthFailAlert) { Button("OK", role: .cancel) {} }
        message: { Text("You need to verify your identity to view the private note.") }
        .onDisappear {
            let t = privateNote.trimmingCharacters(in: .whitespacesAndNewlines)
            store.updatePrivateNote(id: moment.id, note: t.isEmpty ? nil : t)
        }
    }

    private func resetZoom() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            zoomScale = 1.0; zoomOffset = .zero; lastZoomScale = 1.0; lastZoomOffset = .zero
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button { saveToPhotos() } label: {
                HStack(spacing: 8) { Image(systemName: "square.and.arrow.down").font(.system(size: 15)); Text("Save to Photos").font(.system(size: 14, weight: .medium)) }
                .foregroundStyle(Color(UIColor.label)).frame(maxWidth: .infinity).frame(height: 44)
                .background(LiquidGlassBackground(style: .systemUltraThinMaterial)).clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
            }
            Button(role: .destructive) { showDeleteAlert = true } label: {
                HStack(spacing: 8) { Image(systemName: "trash").font(.system(size: 15)); Text("Delete").font(.system(size: 14, weight: .medium)) }
                    .foregroundStyle(Color(UIColor.systemRed)).frame(width: 110, height: 44)
                    .background(LiquidGlassBackground(style: .systemUltraThinMaterial)).clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.25), lineWidth: 1))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
            }
        }
    }

    private func saveToPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    let exportView = PolaroidExportView(moment: moment)
                    let renderer = ImageRenderer(content: exportView)
                    renderer.scale = 3.0
                    renderer.proposedSize = .init(width: 280, height: 352)
                    guard let rendered = renderer.uiImage,
                          let _ = rendered.cgImage else {
                        saveErrorMessage = "Could not render the polaroid. Please try again."
                        showSaveError = true
                        return
                    }
                    UIImageWriteToSavedPhotosAlbum(
                        rendered,
                        PhotoSaveDelegate.shared,
                        #selector(PhotoSaveDelegate.image(_:didFinishSavingWithError:contextInfo:)),
                        nil
                    )
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showSaveSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { withAnimation { showSaveSuccess = false } }
                case .denied, .restricted:
                    saveErrorMessage = "Please allow Photos access in Settings to save this moment."
                    showSaveError = true
                default:
                    saveErrorMessage = "Unable to save. Please try again."
                    showSaveError = true
                }
            }
        }
    }

    private func deleteMoment() { store.deleteMoment(id: moment.id); dismiss() }

    private func sideTapZones(cardWidth: CGFloat) -> some View {
        let e = cardWidth * 0.25
        return HStack(spacing: 0) {
            Color.clear.frame(width: e).contentShape(Rectangle()).onTapGesture { authenticateAndFlip() }
            Spacer()
            Color.clear.frame(width: e).contentShape(Rectangle()).onTapGesture { authenticateAndFlip() }
        }
    }

    private func frontFace(width: CGFloat, height: CGFloat) -> some View {
        let ph = height * 0.78; let ip: CGFloat = 12
        return VStack(spacing: 0) {
            ZStack {
                if let emotion = moment.emotion { LinearGradient(colors: emotion.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { Color(UIColor.systemGray5) }
                Image(uiImage: moment.image).resizable().scaledToFill()
                    .frame(width: width - ip * 2, height: ph - ip * 2).clipped().padding(ip)
            }.frame(width: width, height: ph).clipped()
            VStack(alignment: .leading, spacing: 5) {
                Text(moment.publicReflection).font(.system(size: 13, weight: .regular, design: .serif))
                    .foregroundStyle(Color(UIColor.label)).lineLimit(3).fixedSize(horizontal: false, vertical: true)
                Text(moment.date, style: .date).font(.system(size: 10, weight: .light)).foregroundStyle(Color(UIColor.secondaryLabel))
            }
            .padding(.horizontal, 14).padding(.vertical, 10).frame(width: width, alignment: .leading).frame(maxHeight: .infinity)
            .background(Group {
                if let emotion = moment.emotion { LinearGradient(colors: emotion.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { Color(UIColor.systemBackground) }
            })
        }
        .frame(width: width, height: height).background(Color(UIColor.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
    }

    private func backFace(width: CGFloat, height: CGFloat) -> some View {
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
            }.padding(.horizontal, 18).padding(.top, 20).padding(.bottom, 12)
            Rectangle().fill(Color(UIColor.separator)).frame(height: 0.5).padding(.horizontal, 18)
            ZStack(alignment: .topLeading) {
                linedPaperBackground
                TextEditor(text: $privateNote).font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color(UIColor.label)).scrollContentBackground(.hidden).background(Color.clear)
                    .padding(.horizontal, 12).padding(.top, 6).focused($privateNoteFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") { privateNoteFocused = false }.font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(moment.emotion?.gradient.first?.opacity(0.9) ?? Color(UIColor.label))
                        }
                    }
            }.frame(maxHeight: .infinity)
        }
        .frame(width: width, height: height).background(Color.linedPaper)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
    }

    private var linedPaperBackground: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 28
            ZStack(alignment: .topLeading) {
                Color.clear
                ForEach(0..<Int(geo.size.height / spacing), id: \.self) { i in
                    Rectangle().fill(Color.black.opacity(0.06)).frame(height: 0.5).offset(y: CGFloat(i) * spacing + 44)
                }
            }
        }.allowsHitTesting(false)
    }

    private var flipHint: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.left.and.right").font(.system(size: 11))
            Text(isFlipped ? "Tap either side of the polaroid to return" : "Tap either side of the polaroid to flip").font(.system(size: 12))
        }
        .foregroundStyle(Color(UIColor.secondaryLabel)).animation(.easeInOut(duration: 0.2), value: isFlipped)
    }

    private func authenticateAndFlip() {
        guard zoomScale < 1.05 else { return }
        if isFlipped { flip(); return }
        let hasContent = !privateNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard hasContent else { flip(); return }

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            flip()
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to view your private note.") { success, evaluationError in
            DispatchQueue.main.async {
                if success {
                    self.flip()
                } else {
                    self.showAuthFailAlert = true
                }
            }
        }
    }

    private func flip() {
        privateNoteFocused = false
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) { flipDegrees = isFlipped ? 0.0 : 180.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { isFlipped.toggle() }
    }
}

#Preview {
    NavigationStack {
        MomentDetailView(moment: Moment(image: UIImage(systemName: "photo")!, date: Date(), emotion: emotionList[0], publicReflection: "A lovely memory.", privateBackNote: nil))
            .environment(MomentStore())
    }
}

class PhotoSaveDelegate: NSObject {
    static let shared = PhotoSaveDelegate()

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("PhotoSave error: \(error.localizedDescription)")
        }
    }
}
