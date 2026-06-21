//
//  Color+Theme.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

extension Color {
    static let shelfBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.14, blue: 0.13, alpha: 1)
            : UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1)
    })
    static let binderCover = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.17, blue: 0.16, alpha: 1)
            : UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1)
    })
    static let linedPaper = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.16, blue: 0.15, alpha: 1)
            : UIColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1)
    })
    static let albumAccent = Color(red: 0.35, green: 0.55, blue: 0.85)
    static let mosaicBlue = Color(red: 0.45, green: 0.70, blue: 0.95)
    static let mosaicPurple = Color(red: 0.55, green: 0.45, blue: 0.85)
    static let mosaicOrange = Color(red: 0.95, green: 0.72, blue: 0.48)
}
