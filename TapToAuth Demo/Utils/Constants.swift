//
//  Constants.swift
//  TapToAuth Demo
//
//  Created by Admin on 27/12/2024.
//

struct Constants {
    struct UserDefaultsKeys {
        static let user = "user"
    }
    
    struct APIEndpoints {
        static let baseURL = "https://tap-auth.mspayhub.com/"
        static let login = "v1/login"
        static let fcmTokenUpload = "v1/fcmTokenUpload"
        static let orders = "v1/orders/%@"
    }
}
