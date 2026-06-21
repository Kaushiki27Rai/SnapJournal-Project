//
//  SnapJournalApp.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI

@main
struct SnapJournalApp: App {

    @State private var store = MomentStore()
    @State private var albumStore = AlbumStore()
    @State private var showSplash = true

    @AppStorage("snapjournal.lastTab") private var lastTab = 0
    @AppStorage("snapjournal.lastBackground") private var lastBackground = 0.0

    @Environment(\.scenePhase) private var scenePhase

    private let splashCooldown: TimeInterval = 30 * 60

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView { showSplash = false }
                        .transition(.opacity)
                } else {
                    MainTabView(initialTab: lastTab, onTabChange: { lastTab = $0 })
                        .environment(store)
                        .environment(albumStore)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .animation(.easeInOut(duration: 0.45), value: showSplash)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    lastBackground = Date().timeIntervalSince1970
                }
            }
            .onAppear {
                guard lastBackground > 0 else { return }
                let elapsed = Date().timeIntervalSince1970 - lastBackground
                if elapsed < splashCooldown {
                    showSplash = false
                } else {
                    lastTab = 0
                }
            }
        }
    }
}
