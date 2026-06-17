//
//  EmotionSheet.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct EmotionSheet: View {

    @Binding var selectedEmotion: Emotion?
    var onSelect: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 6) {
                Text("How did this moment feel?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(UIColor.label))
            }
            .padding(.top, 28)
            .padding(.bottom, 24)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(emotionList) { emotion in
                    emotionTile(emotion)
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 24)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private func emotionTile(_ emotion: Emotion) -> some View {
        ZStack(alignment: .topTrailing) {

            Button {
                selectedEmotion = emotion
                onSelect()
            } label: {
                ZStack {
                    LinearGradient(
                        colors: emotion.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Text(emotion.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.67))
                }
                .frame(height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(selectedEmotion?.id == emotion.id ? 0.8 : 0), lineWidth: 2.5)
                )
                .scaleEffect(selectedEmotion?.id == emotion.id ? 1.03 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selectedEmotion?.id)
            }
            .buttonStyle(.plain)

            InfoButton(emotion: emotion)
                .padding(8)
        }
    }

    struct InfoButton: View {
        let emotion: Emotion
        @State private var showInfo = false

        var body: some View {
            Button {
                showInfo = true
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .alert(emotion.name, isPresented: $showInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(emotion.description)
            }
        }
    }
}

#Preview {
    EmotionSheet(selectedEmotion: .constant(nil), onSelect: {})
}
