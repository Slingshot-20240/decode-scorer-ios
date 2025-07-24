//
//  UIApplication.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftUI

extension UIApplication {

    var currentWindowScene: UIWindowScene? {
        return self.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene
    }

    var theKeyWindow: UIWindow? {
        return self.currentWindowScene?
            .windows
            .first(where: \.isKeyWindow)
    }

    var orientedLeft: Bool {
        return self.currentWindowScene?.interfaceOrientation == .landscapeRight
    }

    var orientedRight: Bool {
        return self.currentWindowScene?.interfaceOrientation == .landscapeLeft
    }
}
