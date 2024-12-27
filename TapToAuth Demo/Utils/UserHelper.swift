//
//  UserHelper.swift
//  TapToAuth Demo
//
//  Created by Admin on 27/12/2024.
//

import Foundation

func retrieveUser() -> User? {
    if let savedData = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.user) {
        do {
            let decodedUser = try JSONDecoder().decode(User.self, from: savedData)
            return decodedUser
        } catch {
            print("Failed to decode user: \(error.localizedDescription)")
        }
    }
    return nil
}

func saveUser(userName: String, cardNo: String, token: String) {
    let user = User(userName: userName, cardNo: cardNo, token: token)
    do {
        let encodedData = try JSONEncoder().encode(user)
        UserDefaults.standard.set(encodedData, forKey: Constants.UserDefaultsKeys.user)
    } catch {
        print("Failed to save user: \(error.localizedDescription)")
    }
}
