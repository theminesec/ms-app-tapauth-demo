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
            case .iso7816(let iso7816Tag):
                self.handleIso7816Tag(iso7816Tag, session: session)
            case .miFare(let miFareTag):
                self.handleMiFareTag(miFareTag, session: session)
            default:
                session.invalidate(errorMessage: "Unsupported tag type.")
                self.onReadFailure?("Unsupported tag type.")
            }
        }
    }
    
    private func handleIso7816Tag(_ iso7816Tag: NFCISO7816Tag, session: NFCTagReaderSession) {
        let uid = iso7816Tag.identifier.map { String(format: "%02X", $0) }.joined()
        
        session.invalidate()

        let card = MifareUltraCard(uid: uid, cardNo: "", data: "")
        self.onReadSuccess?(card)
    }
    
    private func handleMiFareTag(_ miFareTag: NFCMiFareTag, session: NFCTagReaderSession) {
        let uid = miFareTag.identifier.map { String(format: "%02X", $0) }.joined()
        
        session.invalidate()
        
        let card = MifareUltraCard(uid: uid, cardNo: "", data: "")
        self.onReadSuccess?(card)
    }
}

struct MifareUltraCard {
    let uid: String
    let cardNo: String
    let data: String
}
