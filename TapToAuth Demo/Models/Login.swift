//
//  LoginResponse.swift
//  TapToAuth Demo
//
//  Created by Admin on 26/12/2024.
//

struct User: Codable {
    let userName: String
    let cardUid: String
    let cardNo: String
    let token: String
}

struct LoginRequest: Codable {
    let userName: String
    let cardUid: String
    let cardNo: String
}
