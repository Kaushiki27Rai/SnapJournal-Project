//
//  PolaroidPreviewView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import AVFoundation

struct PolaroidPreviewView: View {

    var image: UIImage
    var source: PhotoSource

    @State private var selectedEmotion: Emotion?
    @State private var showEmotionSheet = false
    @State private var navigateToReflection = false

    @State private var sheetOpacity: CGFloat = 1.0
    @State private var sheetBlur: CGFloat = 20.0
    @State private var isDeveloping = false
    @State private var hasDeveloped = false
    @State private var showInstruction = true

    private var navigationTitle: String {
        switch source {
        case .camera:  return "Take a Photo"
        case .library: return "Choose from Photos"
        }
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                if showInstruction && !isDeveloping {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 13, weight: .bold))
                        Text("Tap the sheet or shake to develop")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color(UIColor.label))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showInstruction)
                }

                ZStack {
                    polaroidCard

                    if !hasDeveloped {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                            .overlay(
                                Text("Developing...")
                                    .font(.system(size: 13, weight: .light, design: .serif))
                                    .italic()
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                    .opacity(isDeveloping ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.4), value: isDeveloping)
                            )
                            .frame(width: 280, height: 352)
                            .opacity(sheetOpacity)
                            .blur(radius: sheetBlur)
                            .onTapGesture { startDevelopment() }
                            .accessibilityLabel("Developing sheet — your photo is hidden")
                            .accessibilityHint("Double tap to develop the memory. You can also shake your device.")
                    }
                }

                Spacer()

                bottomButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
            startDevelopment()
        }
        .sheet(isPresented: $showEmotionSheet) {
            EmotionSheet(selectedEmotion: $selectedEmotion) {
                showEmotionSheet = false
            }
        }
        .navigationDestination(isPresented: $navigateToReflection) {
            if let emotion = selectedEmotion {
                ReflectionView(image: image, emotion: emotion)
            }
        }
    }

    private func startDevelopment() {
        guard !isDeveloping, !hasDeveloped else { return }

        isDeveloping = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let soundDuration = PolaroidSoundPlayer.shared.playEjectSound()

        withAnimation(.easeInOut(duration: 0.3)) { showInstruction = false }

        let animDelay: TimeInterval = 0.10
        let fadeDuration = max(1.2, min(soundDuration, 5.0))

        DispatchQueue.main.asyncAfter(deadline: .now() + animDelay) {
            withAnimation(.timingCurve(0.4, 0.0, 0.2, 1.0, duration: fadeDuration)) {
                sheetOpacity = 0.0
            }
            withAnimation(.timingCurve(0.6, 0.0, 0.4, 1.0, duration: fadeDuration)) {
                sheetBlur = 0.0
            }
        }

        Task {
            let total = animDelay + fadeDuration
            try? await Task.sleep(nanoseconds: UInt64(total * 1_000_000_000))
            await MainActor.run {
                isDeveloping = false
                hasDeveloped = true
            }
        }
    }

    private var polaroidCard: some View {
        VStack(spacing: 0) {
            ZStack {
                if let emotion = selectedEmotion {
                    LinearGradient(colors: emotion.gradient,
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    Color(UIColor.systemBackground)
                }
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 240, height: 260)
                    .clipped()
                    .padding(16)
            }
            .frame(width: 280, height: 300)
            .clipped()

            HStack { Spacer() }
                .frame(width: 280, height: 52)
                .background(
                    Group {
                        if let emotion = selectedEmotion {
                            LinearGradient(colors: emotion.gradient,
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        } else {
                            Color(UIColor.systemBackground)
                        }
                    }
                )
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .animation(.easeInOut(duration: 0.4), value: selectedEmotion?.id)
    }

    private var bottomButtons: some View {
        VStack(spacing: 14) {
            Button {
                if selectedEmotion == nil {
                    showEmotionSheet = true
                } else {
                    navigateToReflection = true
                }
            } label: {
                Text(selectedEmotion == nil ? "Color the Moment" : "Reflect on the Moment")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(buttonBackground)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(hasDeveloped ? 0.08 : 0), radius: 8, x: 0, y: 4)
            }
            .disabled(!hasDeveloped)
            .opacity(hasDeveloped ? 1.0 : 0.4)
            .animation(.easeInOut(duration: 0.5), value: hasDeveloped)

            if selectedEmotion != nil {
                Button { showEmotionSheet = true } label: {
                    Text("Change emotion")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedEmotion?.id)
    }

    private var buttonBackground: some ShapeStyle {
        if let emotion = selectedEmotion {
            return AnyShapeStyle(LinearGradient(colors: emotion.gradient,
                                                startPoint: .leading, endPoint: .trailing))
        } else {
            return AnyShapeStyle(Color(UIColor.systemBackground))
        }
    }

    private var buttonTextColor: Color {
        selectedEmotion != nil ? .white.opacity(0.9) : Color(UIColor.label)
    }
}

#Preview {
    NavigationStack {
        PolaroidPreviewView(image: UIImage(systemName: "photo")!, source: .library)
    }
}
