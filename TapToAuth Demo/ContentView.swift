//
//  ContentView.swift
//  TapToAuth Demo
//
//  Created by Admin on 18/12/2024.
//

import SwiftUI
import CoreNFC

class NFCReaderViewModel: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var nfcMessage: String = "Tap an NFC tag to read."

    private var session: NFCNDEFReaderSession?

    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            nfcMessage = "NFC reading is not supported on this device."
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your device near an NFC tag."
        session?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate Methods
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.nfcMessage = "Session invalidated: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            if let firstMessage = messages.first,
               let record = firstMessage.records.first,
               let string = String(data: record.payload, encoding: .utf8) {
                self.nfcMessage = "Tag Read: \(string)"
            } else {
                self.nfcMessage = "No valid NDEF message found."
            }
        }
    }
}

struct NFCReaderView: View {
    @StateObject private var viewModel = NFCReaderViewModel()

    var body: some View {
        VStack {
            Text(viewModel.nfcMessage)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                viewModel.startScanning()
            }) {
                Text("Start NFC Scan")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct ContentView: View {
    var body: some View {
        NFCReaderView()
    }
}

#Preview {
    ContentView()
}
