//
//  ReflectionView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

struct ReflectionView: View {

    let image: UIImage
    let emotion: Emotion

    @Environment(MomentStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var publicText = ""
    @State private var privateText = ""
    @State private var isFlipped = false
    @State private var flipDegrees = 0.0

    @FocusState private var publicFocused: Bool
    @FocusState private var privateFocused: Bool

    @State private var hasSaved = false
    @State private var showingSavedBanner = false
    @State private var aiPrompts: [String] = []
    @State private var isLoadingPrompts = false

    private let cardWidth: CGFloat = 280
    private let photoHeight: CGFloat = 252
    private let stripHeight: CGFloat = 80
    private var cardHeight: CGFloat { photoHeight + stripHeight }

    private var canSave: Bool {
        !publicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !hasSaved
    }

    private var showStarters: Bool {
        publicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isFlipped
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    frontFace
                        .rotation3DEffect(.degrees(flipDegrees), axis: (0, 1, 0), perspective: 0.4)
                        .opacity(isFlipped ? 0 : 1)
                    backFace
                        .rotation3DEffect(.degrees(flipDegrees - 180), axis: (0, 1, 0), perspective: 0.4)
                        .opacity(isFlipped ? 1 : 0)
                }
                .frame(width: cardWidth, height: cardHeight)
                .overlay(sideTapZones)

                flipHint.padding(.top, 14)

                if showStarters {
                    aiPromptsSection.frame(width: cardWidth).padding(.top, 12)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                saveButton.padding(.horizontal, 32).padding(.bottom, 48)
            }
            .animation(.easeInOut(duration: 0.2), value: isFlipped)
            .animation(.easeInOut(duration: 0.2), value: showStarters)

            if showingSavedBanner {
                savedBanner.transition(.move(edge: .bottom).combined(with: .opacity)).padding(.bottom, 110)
            }
        }
        .navigationTitle("Reflect on the Moment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { generatePrompts() }
    }

    private var frontFace: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(colors: emotion.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(uiImage: image).resizable().scaledToFill()
                    .frame(width: cardWidth - 24, height: photoHeight - 24).clipped().padding(12)
            }
            .frame(width: cardWidth, height: photoHeight).clipped()

            ZStack(alignment: .center) {
                if emotion.name == "Peaceful" {
                    Color(UIColor.secondarySystemBackground)
                } else {
                    LinearGradient(colors: emotion.gradient.map { $0.opacity(0.85) },
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Color(UIColor.systemBackground).opacity(0.15)
                }

                let textColor: Color = emotion.name == "Peaceful" ? Color(UIColor.label) : .white

                ZStack(alignment: .leading) {
                    if publicText.isEmpty {
                        Text("I am feeling \(emotion.name.lowercased())...")
                            .font(.system(size: 12, weight: .light, design: .serif)).italic()
                            .foregroundStyle(textColor.opacity(0.55))
                            .padding(.horizontal, 12).allowsHitTesting(false)
                    }
                    TextEditor(text: $publicText)
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .foregroundStyle(textColor)
                        .scrollContentBackground(.hidden).background(Color.clear)
                        .padding(.horizontal, 8).focused($publicFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") { publicFocused = false; privateFocused = false }
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(emotion.gradient.first?.opacity(0.9) ?? Color(UIColor.label))
                            }
                        }
                }
                .frame(height: 56)
                .background(emotion.name == "Peaceful" ? Color.black.opacity(0.06) : Color(UIColor.systemBackground).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(emotion.name == "Peaceful" ? Color.black.opacity(0.15) : Color.white.opacity(0.35), lineWidth: 1))
                .padding(.horizontal, 12).padding(.vertical, 10)
            }
            .frame(width: cardWidth, height: stripHeight)
            .onTapGesture { publicFocused = true }
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }

    private var backFace: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Private").font(.system(size: 10, weight: .medium))
                        .foregroundStyle(emotion.gradient.first ?? .secondary)
                        .kerning(1.5).textCase(.uppercase)
                    Spacer()
                    Image(systemName: "lock.fill").font(.system(size: 10))
                        .foregroundStyle(emotion.gradient.first ?? .secondary)
                }
                Text("Would you like to share more...?")
                    .font(.system(size: 12, weight: .light, design: .serif)).italic()
                    .foregroundStyle(Color(UIColor.label).opacity(0.6))
            }
            .padding(.horizontal, 18).padding(.top, 18).padding(.bottom, 10)

            Rectangle().fill(Color(UIColor.separator)).frame(height: 0.5).padding(.horizontal, 18)

            ZStack(alignment: .topLeading) {
                linedPaper
                TextEditor(text: $privateText)
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(Color(UIColor.label))
                    .scrollContentBackground(.hidden).background(Color.clear)
                    .padding(.horizontal, 12).padding(.top, 4).focused($privateFocused)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(Color.linedPaper)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }

    private var linedPaper: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 26
            ZStack(alignment: .topLeading) {
                Color.clear
                ForEach(0..<Int(geo.size.height / spacing), id: \.self) { i in
                    Rectangle().fill(Color.black.opacity(0.06)).frame(height: 0.5)
                        .offset(y: CGFloat(i) * spacing + 42)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var aiPromptsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").font(.system(size: 11))
                    .foregroundStyle(emotion.gradient.first ?? .secondary)
                Text("Sentence starters").font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                Spacer()
                if isLoadingPrompts {
                    ProgressView().scaleEffect(0.6)
                } else {
                    Button { generatePrompts() } label: {
                        Image(systemName: "arrow.clockwise").font(.system(size: 11))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                }
            }

            if !aiPrompts.isEmpty {
                VStack(spacing: 6) {
                    ForEach(aiPrompts, id: \.self) { prompt in
                        Button { applyPrompt(prompt) } label: {
                            HStack {
                                Text(prompt)
                                    .font(.system(size: 12, weight: .light, design: .serif)).italic()
                                    .foregroundStyle(Color(UIColor.label)).multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "plus.circle").font(.system(size: 12))
                                    .foregroundStyle(emotion.gradient.first?.opacity(0.8) ?? .secondary)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func generatePrompts() {
        guard !isLoadingPrompts else { return }
        isLoadingPrompts = true
        aiPrompts = []

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Task { await generateUsingFoundationModel() }
            return
        }
        #endif

        useOfflineFallback()
    }

    private func useOfflineFallback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.aiPrompts = Array(self.offlineFallback.shuffled().prefix(3))
                self.isLoadingPrompts = false
            }
        }
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateUsingFoundationModel() async {
        do {
            let session = LanguageModelSession()
            let prompt = """
            You are a silent journaling tool. Your only output is exactly 3 diary \
            sentence starters for someone feeling \(emotion.name), one per line, nothing else.
            Every line is first-person, unfinished, ends with an ellipsis (…).
            Every line is 5–10 words before the ellipsis.
            No numbering, bullets, dashes, or list markers.
            """
            let resp = try await session.respond(to: prompt)
            let lines = sanitised(
                resp.content
                    .split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .map { String($0) }
            )
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    aiPrompts = lines.isEmpty ? Array(offlineFallback.shuffled().prefix(3)) : Array(lines.prefix(3))
                    isLoadingPrompts = false
                }
            }
        } catch {
            useOfflineFallback()
        }
    }
    #endif

    private func sanitised(_ lines: [String]) -> [String] {
        let blocked = [
            "sure", "here are", "certainly", "of course", "i'd be happy", "happy to help",
            "i'm sorry", "i cannot", "i can't", "i won't", "i apologize", "apologies", "sorry",
            "as an ai", "i am unable", "i'm unable", "unable to", "not able to",
            "please note", "note that", "these are", "below are", "the following", "here's",
            "would you like", "what if", "instead", "let me know", "feel free",
            "self-harm", "reach out", "crisis", "lifeline", "mental health", "professional",
            "struggling", "support", "?"
        ]
        let badPrefixes = ["1.", "2.", "3.", "4.", "5.", "-", "•", "*", "#"]
        return lines.filter { line in
            let lower = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard lower.count >= 8 else { return false }
            for prefix in badPrefixes where lower.hasPrefix(prefix) { return false }
            for sub in blocked where lower.contains(sub) { return false }
            return true
        }
    }

    private var offlineFallback: [String] {
        let bank: [String: [String]] = [
            "Calm":       ["I felt still when…", "What slowed me down today was…", "I found quiet in…",
                           "There was nothing urgent about…", "I breathed a little easier because…",
                           "The only thing that mattered was…"],
            "Joyful":     ["I smiled because…", "The best part was…", "I didn't expect to feel this happy when…",
                           "Something small made today worth it…", "I felt light today when…",
                           "I wanted to hold onto this moment because…"],
            "Reflective": ["This made me think about…", "I realised something when…", "Looking back, I notice…",
                           "There's a pattern I'm starting to see…", "I want to sit with the thought that…",
                           "I wasn't expecting to learn that…"],
            "Energized":  ["I felt most alive when…", "Something sparked in me today…", "I couldn't wait to…",
                           "Everything clicked when I…", "I surprised myself by…",
                           "I moved through today like…"],
            "Passionate": ["This mattered deeply because…", "I felt strongly about…",
                           "I couldn't ignore the feeling that…", "Something inside me lit up when…",
                           "I cared more than I expected about…", "The thing that moved me most was…"],
            "Nostalgic":  ["This reminded me of…", "It took me back to…", "I missed the way…",
                           "A memory surfaced that I hadn't visited in a while…",
                           "The feeling was familiar in a way that…",
                           "I found myself thinking of a time when…"],
            "Drained":    ["Everything felt like too much when…", "I needed rest because…",
                           "What exhausted me today was…", "I gave more than I had when…",
                           "By the end, all I wanted was…", "Something kept pulling at my energy today…"],
            "Peaceful":   ["There was nothing to fix here…", "I felt okay just being…",
                           "This moment simply was…", "I didn't need anything more than…",
                           "I sat with it instead of solving it…", "Nothing needed to change in that moment…"],
            "Worried":    ["My mind kept returning to…", "I couldn't stop thinking about…",
                           "What unsettled me most was…", "There was a knot in me around…",
                           "I kept checking on the thought that…", "What I wish I could know is…"],
            "Grateful":   ["I didn't expect to feel thankful for…", "Something small meant a lot because…",
                           "I want to remember this because…", "The thing I almost overlooked today was…",
                           "I took a second to actually appreciate…", "I felt held by…"],
        ]
        return bank[emotion.name] ?? [
            "This moment felt…", "I noticed that…", "What stayed with me was…",
            "Something shifted when…", "I'm holding onto the feeling that…", "Today reminded me that…"
        ]
    }

    private func applyPrompt(_ prompt: String) {
        publicText = publicText.isEmpty
            ? prompt + " "
            : publicText.trimmingCharacters(in: .whitespacesAndNewlines) + " " + prompt + " "
        publicFocused = true
    }

    private var sideTapZones: some View {
        let e = cardWidth * 0.25
        return HStack(spacing: 0) {
            Color.clear.frame(width: e, height: cardHeight).contentShape(Rectangle()).onTapGesture { flip() }
            Spacer()
            Color.clear.frame(width: e, height: cardHeight).contentShape(Rectangle()).onTapGesture { flip() }
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    private func flip() {
        publicFocused = false; privateFocused = false
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
            flipDegrees = isFlipped ? 0 : 180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { isFlipped.toggle() }
    }

    private var flipHint: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.left.and.right").font(.system(size: 11))
            Text(isFlipped ? "Tap either side of the polaroid to return" : "Tap either side of the polaroid to flip")
                .font(.system(size: 12))
        }
        .foregroundStyle(Color(UIColor.secondaryLabel))
        .animation(.easeInOut(duration: 0.2), value: isFlipped)
    }

    private var saveButton: some View {
        Button { saveMoment() } label: {
            Text(hasSaved ? "Saved ✓" : "Save")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(canSave ? .black.opacity(0.7) : Color(UIColor.tertiaryLabel))
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(canSave
                    ? AnyShapeStyle(LinearGradient(colors: emotion.gradient, startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(UIColor.systemGray5)))
                .clipShape(Capsule())
                .shadow(color: canSave ? (emotion.gradient.first?.opacity(0.35) ?? .clear) : .clear,
                        radius: 10, x: 0, y: 5)
        }
        .disabled(!canSave)
        .animation(.easeInOut(duration: 0.2), value: canSave)
    }

    private var savedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.black.opacity(0.7))
            Text("Moment saved").font(.system(size: 15)).foregroundStyle(.black.opacity(0.7))
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(Capsule().fill(
            LinearGradient(colors: emotion.gradient, startPoint: .leading, endPoint: .trailing)
        ))
        .shadow(color: emotion.gradient.first?.opacity(0.35) ?? .clear, radius: 12, x: 0, y: 6)
    }

    private func saveMoment() {
        let trimmed = publicText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let back = privateText.trimmingCharacters(in: .whitespacesAndNewlines)
        store.addMoment(Moment(
            image: image, date: Date(), emotion: emotion,
            publicReflection: trimmed,
            privateBackNote: back.isEmpty ? nil : back
        ))
        hasSaved = true; publicFocused = false; privateFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showingSavedBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { store.justSaved = true }
    }
}

#Preview {
    NavigationStack {
        ReflectionView(image: UIImage(systemName: "photo")!, emotion: emotionList[0])
            .environment(MomentStore())
    }
}
