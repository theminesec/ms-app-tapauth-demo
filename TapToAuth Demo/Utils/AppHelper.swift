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

extension Int {
    func getLocalFormattedTime() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))

        let timeZone = TimeZone.current

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        formatter.timeZone = timeZone

        return formatter.string(from: date)
    }

    func formatTimeRemaining(enablePrefix: Bool = true) -> String {
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let remainingSeconds = self - currentTimestamp

        if remainingSeconds <= 0 {
            return "Expired"
        }

        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        var displayMsg = enablePrefix ? "Expires in: " : ""
        if minutes > 0 {
            displayMsg += "\(minutes)m "
        }
        if seconds >= 0 {
            displayMsg += "\(seconds)s"
        }

        return displayMsg
    }
}
