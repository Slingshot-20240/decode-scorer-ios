//
//  Haptics.swift
//  DECODE
//
//  Created by Jining Liu on 7/21/25.
//

import UIKit

struct Haptics {
    static func play(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle,
        intensity: CGFloat = 1
    ) {
        UIImpactFeedbackGenerator(style: style)
            .impactOccurred(intensity: intensity)
    }

    static func notify(
        _ type: UINotificationFeedbackGenerator.FeedbackType
    ) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
