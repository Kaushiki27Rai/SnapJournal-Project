//
//  LiquidGlassBackground.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct LiquidGlassBackground: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: style))
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        return v
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
