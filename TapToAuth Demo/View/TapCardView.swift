//
//  TapCardView.swift
//  TapToAuth Demo
//
//  Created by Admin on 21/12/2024.
//

import SwiftUI
import AVKit

struct TapCardView: View {
    let userName: String
    @Environment(\.colorScheme) var colorScheme
    @State private var player: AVPlayer?
    @State private var countdown: Int = 10
    @State private var navigateToHome: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tap & Login")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.gray)
                Text("tap your card to login")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            VStack {
                let videoName = colorScheme == .dark ? "anim_await_card_night" : "anim_await_card_day"

                if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
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
                Text("Tap to Login")
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
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView(userName: userName)
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

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                navigateToHome = true
            }
        }
    }
}
