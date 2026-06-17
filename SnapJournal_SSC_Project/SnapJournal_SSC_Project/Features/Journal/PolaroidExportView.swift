//
//  PolaroidExportView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct PolaroidExportView: View {
    let moment: Moment
    private let cw: CGFloat = 340
    private let ph: CGFloat = 340 * 0.78
    private let ip: CGFloat = 12

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let emotion = moment.emotion { LinearGradient(colors: emotion.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { Color(UIColor.systemGray5) }
                Image(uiImage: moment.image).resizable().scaledToFill().frame(width: cw - ip*2, height: ph - ip*2).clipped().padding(ip)
            }.frame(width: cw, height: ph).clipped()
            VStack(alignment: .leading, spacing: 5) {
                if !moment.publicReflection.isEmpty {
                    Text(moment.publicReflection).font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundStyle(Color(UIColor.label)).lineLimit(3).fixedSize(horizontal: false, vertical: true)
                }
                Text(moment.date, style: .date).font(.system(size: 10, weight: .light)).foregroundStyle(Color(UIColor.secondaryLabel))
            }
            .padding(.horizontal, 14).padding(.vertical, 12).frame(width: cw, alignment: .leading)
            .background(Group {
                if let emotion = moment.emotion { LinearGradient(colors: emotion.gradient, startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { Color.white }
            })
        }
        .frame(width: cw).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
    }
}

#Preview {
    PolaroidExportView(moment: Moment(image: UIImage(systemName: "photo")!, date: Date(), emotion: emotionList[0], publicReflection: "A lovely memory.", privateBackNote: nil))
}
