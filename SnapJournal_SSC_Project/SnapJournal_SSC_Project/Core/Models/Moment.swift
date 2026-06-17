//
//  Moment.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import Foundation
import SwiftUI

struct Moment: Identifiable {
    var id: UUID = UUID()
    let image: UIImage
    let date: Date
    let emotion: Emotion?
    let publicReflection: String
    var privateBackNote: String?

    var hasPrivateNote: Bool {
        guard let note = privateBackNote else { return false }
        return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
