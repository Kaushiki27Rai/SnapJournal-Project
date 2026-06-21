//
//  SplashView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct SplashView: View {

    var onFinished: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    @State private var iconScale = 0.35
    @State private var iconOpacity = 0.0
    @State private var glowRadius = 0.0
    @State private var glowOpacity = 0.0
    @State private var nameOffset = 28.0
    @State private var nameOpacity = 0.0
    @State private var taglineOpacity = 0.0

    private let gradientTop = Color(red: 0.85, green: 0.72, blue: 0.48)
    private let gradientBottom = Color(red: 0.88, green: 0.55, blue: 0.52)
    private let accentGlow = Color(red: 1.00, green: 0.90, blue: 0.80)

    private var iconAssetName: String {
        switch colorScheme {
        case .dark:  return "AppIconDark"
        case .light: return "AppIconLight"
        @unknown default: return "AppIconClear"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [gradientTop, gradientBottom],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Canvas { context, size in
                let centre = CGPoint(x: size.width / 2, y: size.height * 0.42)
                let radius = size.width * 0.65
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: centre.x - radius, y: centre.y - radius,
                        width: radius * 2, height: radius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [Color.white.opacity(0.18), .clear]),
                        center: centre, startRadius: 0, endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(accentGlow.opacity(glowOpacity))
                        .frame(width: 148, height: 148)
                        .blur(radius: glowRadius)

                    Circle()
                        .fill(Color.white.opacity(glowOpacity * 0.35))
                        .frame(width: 110, height: 110)
                        .blur(radius: glowRadius * 0.5)

                    Group {
                        if UIImage(named: iconAssetName) != nil {
                            Image(iconAssetName)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image("light")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(width: 112, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .shadow(color: Color(red: 0.75, green: 0.40, blue: 0.35).opacity(0.38),
                            radius: 24, x: 0, y: 12)
                    .shadow(color: Color.white.opacity(0.22), radius: 6, x: 0, y: -3)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                Text("SnapJournal")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .white.opacity(0.82)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                    .padding(.top, 28)
                    .offset(y: nameOffset)
                    .opacity(nameOpacity)

                Text("Your moments, quietly kept.")
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(Color.white.opacity(0.72))
                    .padding(.top, 8)
                    .offset(y: nameOffset)
                    .opacity(taglineOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear { runAnimation() }
    }

    private func runAnimation() {
        withAnimation(.spring(response: 0.65, dampingFraction: 0.60)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.45).delay(0.30)) {
            glowOpacity = 0.55
            glowRadius = 28
        }
        withAnimation(.easeInOut(duration: 1.8).repeatCount(3, autoreverses: true).delay(0.75)) {
            glowRadius = 44
            glowOpacity = 0.22
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.50)) {
            nameOffset = 0
            nameOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.95)) {
            taglineOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.50) {
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
