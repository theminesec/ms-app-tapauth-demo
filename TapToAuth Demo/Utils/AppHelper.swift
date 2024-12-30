//
//  AppHelper.swift
//  TapToAuth Demo
//
//  Created by Admin on 27/12/2024.
//

import SwiftUI

extension UIApplication {
    func resetRootView<Content: View>(to view: Content) {
        guard let window = connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
            return
        }
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
    }
}

extension TimeInterval {
    func getLocalFormattedTime() -> String {
        // Convert Unix timestamp (seconds) to Date
        let date = Date(timeIntervalSince1970: self)

        // Get the device's current time zone
        let timeZone = TimeZone.current

        // Create a date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone

        // Format the date and return as a string
        return formatter.string(from: date)
    }
}

extension TimeInterval {
    func formatTimeRemaining(enablePrefix: Bool = true) -> String {
        let currentTimestamp = Date().timeIntervalSince1970 // Current Unix time (seconds)
        let remainingSeconds = self - currentTimestamp

        if remainingSeconds <= 0 {
            return "Expired"
        }

        let minutes = Int(remainingSeconds) / 60
        let seconds = Int(remainingSeconds) % 60

        var displayMsg = enablePrefix ? "Expires in: " : ""
        if minutes > 0 {
            displayMsg += "\(minutes)m "
        }
        displayMsg += "\(seconds)s"

        return displayMsg
    }
}

