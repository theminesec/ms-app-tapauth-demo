//
//  ContentView.swift
//  TapToAuth Demo
//
//  Created by Admin on 18/12/2024.
//

import SwiftUI
import CoreNFC

struct NFCReaderView: View {
    @State private var message: String = ""
    private let nfcReader = NFCMiFareUltralight()

    var body: some View {
        VStack(spacing: 20) {
            Text("NFC Reader")
                .font(.title)

            Text(message)
                .foregroundColor(.gray)

            Button(action: startNFC) {
                Text("Start NFC Session")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            setupCallbacks()
        }
    }

    private func startNFC() {
        nfcReader.startSession()
    }

    private func setupCallbacks() {
        nfcReader.onReadSuccess = { card in
            message = "Card UID: \(card.uid)\nCard Data: \(card.cardNo)"
        }

        nfcReader.onReadFailure = { error in
            message = "Error: \(error)"
        }
    }
}
