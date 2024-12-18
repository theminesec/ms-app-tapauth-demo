//
//  ContentView.swift
//  TapToAuth Demo
//
//  Created by Admin on 18/12/2024.
//

import SwiftUI
import CoreNFC

struct NFCReaderView: View {
    @State private var message: String = "Tap the button to scan NFC tags."
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var nfcSession: NFCNDEFReaderSession?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
            
            Button(action: startNFCSession) {
                Text("Scan NFC Tag")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
    }
    
    private func startNFCSession() {
        guard NFCNDEFReaderSession.readingAvailable else {
            alertMessage = "NFC is not available on this device."
            showingAlert = true
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: NFCSessionDelegate { result in
            switch result {
            case .success(let payload):
                DispatchQueue.main.async {
                    self.message = "Read NFC Tag: \(payload)"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                }
            }
        }, queue: nil, invalidateAfterFirstRead: true)
        
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
    }
}

// MARK: - NFC Delegate Handler
class NFCSessionDelegate: NSObject, NFCNDEFReaderSessionDelegate {
    private let completion: (Result<String, Error>) -> Void
    
    init(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError, nfcError.code != .readerSessionInvalidationErrorUserCanceled {
            completion(.failure(nfcError))
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let payload = String(data: record.payload, encoding: .utf8) {
                    completion(.success(payload))
                    return
                }
            }
        }
        completion(.failure(NSError(domain: "NFCReader", code: -1, userInfo: [NSLocalizedDescriptionKey: "No valid NFC data found."])))
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
