//
//  ViewModels.swift
//  TapToAuth Demo
//
//  Created by Admin on 26/12/2024.
//

import Foundation
import FirebaseMessaging

class LoginViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var alertMessage: String? = nil

    private let nfcReader = NFCMiFareUltralight()

    func startLoginProcess(userName: String) {
        isLoading = true

        nfcReader.startSession()
        nfcReader.onReadFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.alertMessage = error
                self?.isLoading = false
            }
        }

        nfcReader.onReadSuccess = { [weak self] card in
            DispatchQueue.main.async {
                print("Card Number: \(card.cardNo)")
                self?.performLogin(userName: userName, cardNo: card.cardNo)
            }
        }
    }

    func performLogin(userName: String, cardNo: String) {
        Messaging.messaging().token { [weak self] token, error in
            guard let self = self else { return }
            if let error = error {
                self.alertMessage = "Failed to retrieve FCM token: \(error.localizedDescription)"
                self.isLoading = false
                return
            }

            guard let fcmToken = token else {
                self.requestNotificationPermission()
                return
            }

            let loginRequest = LoginRequest(userName: userName, cardNo: cardNo)
            NetworkClient.shared.post(
                endpoint: .login,
                body: loginRequest,
                responseType: BaseResponse<User>.self
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.code == 0 {
                            saveUser(userName: userName, cardNo: cardNo, token: response.body.token)
                            self.uploadFcmToken(cardNo: cardNo, token: fcmToken, userName: userName)
                            self.alertMessage = response.message
                            self.isLoading = false
                        }
                    case .failure(let error):
                        self.alertMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        }
    }

    private func uploadFcmToken(cardNo: String, token: String, userName: String) {
        let fcmRequest = FcmTokenRequest(cardNo: cardNo, fcmToken: token)
        NetworkClient.shared.post(
            endpoint: .fcmTokenUpload,
            body: fcmRequest,
            responseType: BaseResponse<FcmTokenResponseBody>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success:
                    self.isLoggedIn = true
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                } else {
                    self?.alertMessage = "Notification permissions are required for login."
                    self?.isLoading = false
                }
            }
        }
    }
}
