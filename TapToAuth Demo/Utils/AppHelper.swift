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
