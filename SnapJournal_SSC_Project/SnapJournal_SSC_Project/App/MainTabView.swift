//
//  MainTabView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

struct MainTabView: View {

    var initialTab: Int
    var onTabChange: ((Int) -> Void)?

    @State private var selectedTab: Int

    init(initialTab: Int = 0, onTabChange: ((Int) -> Void)? = nil) {
        self.initialTab = initialTab
        self.onTabChange = onTabChange
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            ContentView()
                .tabItem { Label("Journal", systemImage: "camera.viewfinder") }
                .tag(0)

            MoodMosaicView()
                .tabItem { Label("Mosaic", systemImage: "calendar") }
                .tag(1)

            BookshelfView()
                .tabItem { Label("Shelf", systemImage: "books.vertical") }
                .tag(2)
        }
        .tint(Color(UIColor.label))
        .onChange(of: selectedTab) { _, newTab in
            onTabChange?(newTab)
        }
    }
}

#Preview {
    MainTabView()
        .environment(MomentStore())
        .environment(AlbumStore())
}
