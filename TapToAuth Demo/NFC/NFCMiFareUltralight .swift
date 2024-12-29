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
        session?.alertMessage = "Hold your device near the MineSec Card."
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
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                self.onReadFailure?("Connection failed: \(error.localizedDescription)")
                return
            }

            switch tag {
            case .miFare(let miFareTag):
                self.readMifareUltralightTag(miFareTag, session: session)
            default:
                session.invalidate(errorMessage: "Tag is not a Mifare Ultralight card.")
                self.onReadFailure?("Tag is not a Mifare Ultralight card.")
            }
        }
    }

    private func readMifareUltralightTag(_ miFareTag: NFCMiFareTag, session: NFCTagReaderSession) {
        // Read pages 4 to 6
        let startPage: UInt8 = 4
        let readCommand = Data([0x30, startPage])

        miFareTag.sendMiFareCommand(commandPacket: readCommand) { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                self.onReadFailure?("Read failed: \(error.localizedDescription)")
                return
            }

            if response.count < 16 {
                session.invalidate(errorMessage: "Invalid data read from card.")
                self.onReadFailure?("Invalid data read from card.")
                return
            }

            let uid = miFareTag.identifier.map { String(format: "%02X", $0) }.joined()

            let fixedPart = "4386"
            let xxxx = response[0..<4].map { String(format: "%02X", $0) }.joined() // Page 4
            let yyyy = response[4..<8].map { String(format: "%02X", $0) }.joined() // Page 5
            let zzzz = response[8..<12].map { String(format: "%02X", $0) }.joined() // Page 6

            let cardNumber = "\(fixedPart) \(xxxx) \(yyyy) \(zzzz)"
            
            let rawData = response.map { String(format: "%02X", $0) }.joined()

            session.invalidate()

            self.onReadSuccess?(MifareUltraCard(uid: uid, cardNo: cardNumber, data: rawData))
        }
    }
}

struct MifareUltraCard {
    let uid: String
    let cardNo: String
    let data: String
}
