//
//  Base.swift
//  TapToAuth Demo
//
//  Created by Admin on 26/12/2024.
//

struct BaseResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let body: T
}
