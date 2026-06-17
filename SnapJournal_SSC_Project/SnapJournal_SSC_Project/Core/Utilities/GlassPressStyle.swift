//
//  GlassPressStyle.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct GlassPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.2) : Color.clear)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
