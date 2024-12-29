//
//  TapCardView.swift
//  TapToAuth Demo
//
//  Created by Admin on 21/12/2024.
//

import SwiftUI
import AVKit

struct TapCardView: View {
    let amount: String
    @Environment(\.colorScheme) var colorScheme
    @State private var player: AVPlayer?
    @State private var countdown: Int = 10

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total amount")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                Text("$\(amount)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            VStack {
                let videoName = colorScheme == .dark ? "anim_await_card_night" : "anim_await_card_day"
                //Remove usage of dark video
                if let videoURL = Bundle.main.url(forResource: "anim_await_card_day", withExtension: "mp4") {
                    VideoPlayer(player: player)
                        .onAppear {
                            player = AVPlayer(url: videoURL)
                            setupPlayerLooping()
                            player?.play()
                            startCountdown()
                        }
                        .onDisappear {
                            player?.pause()
                            player = nil
                        }
                        .frame(width: 250, height: 250)
                } else {
                    Text("Video not found")
                        .foregroundColor(.red)
                }
            }
            
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("Tap to Pay")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Text("Tap and hold card to the back of device")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Text("\(countdown)s")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.green)

                // Payment Icons
                HStack(spacing: 12) {
                    Image("visa")
                    Image("mastercard")
                    Image("apple_pay")
                    Image("google_pay")
                    Image("samsung_pay")
                    Image("huawei_pay")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)

            Spacer()
            
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
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

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
