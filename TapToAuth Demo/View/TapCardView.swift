//
//  TapCardView.swift
//  TapToAuth Demo
//
//  Created by Admin on 21/12/2024.
//

import SwiftUI
import AVKit

struct TapCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            // Determine video based on color scheme
            let videoName = colorScheme == .dark ? "anim_await_card_night" : "anim_await_card_day"
            
            if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                VideoPlayer(player: player)
                    .onAppear {
                        player = AVPlayer(url: videoURL)
                        setupPlayerLooping()
                        player?.play()
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
            } else {
                Text("Video not found")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func setupPlayerLooping() {
        guard let player = player else { return }
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}
