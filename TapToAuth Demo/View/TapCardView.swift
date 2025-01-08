//
//  TapCardView.swift
//  TapToAuth Demo
//
//  Created by Admin on 21/12/2024.
//

import SwiftUI
import AVKit

struct TapCardView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var player: AVPlayer?
    @State private var countdown: Int = 10
    private let nfcReader = NFCMiFareUltralight()

    var body: some View {
        if let order = viewModel.selectedOrder {
            ZStack {
                VStack(spacing: 20) {
                    // Total amount
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total amount")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Text("$\(order.amount)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer()

                    // Video animation
                    VStack {
                        if let videoURL = Bundle.main.url(forResource: "anim_await_card_day", withExtension: "mp4") {
                            VideoPlayer(player: player)
                                .onAppear {
                                    player = AVPlayer(url: videoURL)
                                    setupPlayerLooping()
                                    player?.play()
                                    startCountdown()
                                    startNFCSession()
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

                    // Tap to Pay instructions
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

                VStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
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
//                viewModel.updateOrderStatus(actionId: viewModel.selectedOrder, newStatus: <#T##ActionStatus#>)(to: .timeout)
                dismiss()
            }
        }
    }

    private func startNFCSession() {
        nfcReader.onReadSuccess = { card in
            print("Card scanned successfully: \(card.cardNo)")
            viewModel.confirmOrder(actionId: viewModel.selectedOrder!.actionId, cardUid: card.uid, cardNo: card.cardNo){ result in
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    print("Failed to update action: \(error.localizedDescription)")
                }
            }
        }

        nfcReader.onReadFailure = { error in
            print("NFC scan failed: \(error)")
            dismiss()
        }

        nfcReader.startSession()
    }
}
