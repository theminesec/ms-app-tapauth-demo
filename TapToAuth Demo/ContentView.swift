//
//  ContentView.swift
//  TapToAuth Demo
//
//  Created by Admin on 18/12/2024.
//

import SwiftUI
import CoreNFC

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
