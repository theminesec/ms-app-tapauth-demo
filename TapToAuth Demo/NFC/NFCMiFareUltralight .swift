//
//  NFCMiFareUltralight .swift
//  TapToAuth Demo
//
//  Created by Admin on 21/12/2024.
//
import CoreNFC

class NFCMiFareUltralight: NSObject, NFCTagReaderSessionDelegate {
    private var session: NFCTagReaderSession?
    var onReadSuccess: ((MifareUltraCard) -> Void)?
    var onReadFailure: ((String) -> Void)?
    
    func startSession() {
        guard NFCNDEFReaderSession.readingAvailable else {
            onReadFailure?("NFC is not supported on this device.")
            return
        }
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your device near the NFC tag."
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session is now active.")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        onReadFailure?("Session invalidated: \(error.localizedDescription)")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tags found.")
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                session.invalidate(errorMessage: "Failed to connect to the tag: \(error.localizedDescription)")
                self.onReadFailure?("Connection failed: \(error.localizedDescription)")
                return
            }

            switch tag {
            case .miFare(let miFareTag):
                self.handleNormalCardTap(miFareTag, session: session)
            default:
                self.handleSimulatedCardTap(session: session)
            }
        }
    }

    private func handleNormalCardTap(_ miFareTag: NFCMiFareTag, session: NFCTagReaderSession) {
        let startPage: UInt8 = 4
        let numberOfPages = 3
        let readCommand = Data([0x30, startPage]) // Read command for page 4

        miFareTag.sendMiFareCommand(commandPacket: readCommand) { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                self.onReadFailure?("Read failed: \(error.localizedDescription)")
                return
            }

            if response.count < (numberOfPages * 4) {
                session.invalidate(errorMessage: "Invalid data read from card.")
                self.onReadFailure?("Invalid data read from card.")
                return
            }

            let page4 = response[0..<4].map { String(format: "%02X", $0) }.joined()
            let page5 = response[4..<8].map { String(format: "%02X", $0) }.joined()
            let page6 = response[8..<12].map { String(format: "%02X", $0) }.joined()
            let cardNumber = "\(page4)\(page5)\(page6)".replacingOccurrences(of: "F", with: "")

            let uid = miFareTag.identifier.map { String(format: "%02X", $0) }.joined()
            let rawData = response.map { String(format: "%02X", $0) }.joined()

            print("Card UID: \(uid), Card Number: \(cardNumber), Raw Data: \(rawData)")

            session.invalidate()

            let card = MifareUltraCard(uid: uid, cardNo: cardNumber, data: rawData)
            self.onReadSuccess?(card)
        }
    }

    private func handleSimulatedCardTap(session: NFCTagReaderSession) {
        session.invalidate()
        let card = MifareUltraCard(uid: "Simulated", cardNo: "simulatedCardNo", data: "Simulated data")
        self.onReadSuccess?(card)
    }
}

struct MifareUltraCard {
    let uid: String
    let cardNo: String
    let data: String
}
