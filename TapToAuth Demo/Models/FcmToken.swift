//
//  FCMToken.swift
//  TapToAuth Demo
//
//  Created by Admin on 26/12/2024.
//

struct FcmTokenRequest: Codable {
    let cardNo: String
    let fcmToken: String
}

struct FcmTokenResponseBody: Codable {
    let cardNo: String
    let fcmToken: String
}
