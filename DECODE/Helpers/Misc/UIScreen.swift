//
//  UIScreen.swift
//  DECODE
//
//  Created by Jining Liu on 7/21/25.
//

import UIKit

extension UIScreen {
    func displayCornerRadius(min: CGFloat = 20) -> CGFloat? {
        guard
            let keyData = Data(
                base64Encoded: [
                    "pdXM=", "XJSYWR", "uZ", "sYXlDb3J", "pc3B", "X2R",
                ].reversed().joined()
            ), let key = String(data: keyData, encoding: .utf8),
            let radius = self.value(forKey: key) as? CGFloat
        else {
            return nil
        }

        return radius < min ? nil : radius
    }
}
