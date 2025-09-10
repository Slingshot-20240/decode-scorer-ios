//
//  Aptabase.swift
//  DECODE
//
//  Created by Jining Liu on 9/9/25.
//

import Aptabase
import Foundation
import SwiFTC

extension Aptabase {
    func launch() {
        if !APTABASE_APP_KEY.isEmpty {
            self.initialize(appKey: APTABASE_APP_KEY)
            self.trackEvent("launch")
        }
    }

    func trackFeature(_ type: Analytics.FeatureTrackingType) {
        self.trackEvent("feature", with: ["feature": type.rawValue])
    }

    func trackElements(
        _ scores: DecodeGameScores,
        from type: Analytics.ElementsTrackingType
    ) {
        if !APTABASE_APP_KEY.isEmpty {
            let classified =
                scores.red.auto.classfied + scores.red.teleop.classfied
                + scores.blue.auto.classfied + scores.blue.teleop.classfied
            let overflown =
                scores.red.auto.overflown + scores.red.teleop.overflown
                + scores.blue.auto.overflown + scores.blue.teleop.overflown
            let depot = scores.red.teleop.depot + scores.blue.teleop.depot
            let artifacts = classified + overflown + depot

            let motifs =
                scores.red.auto.matchingMotifs
                + scores.red.teleop.matchingMotifs
                + scores.blue.auto.matchingMotifs
                + scores.blue.teleop.matchingMotifs

            if artifacts + motifs > 0 {
                self.trackEvent(
                    "elements",
                    with: [
                        "classified": classified,
                        "overflown": overflown,
                        "depot": depot,
                        "artifacts": artifacts,
                        "motifs": motifs,
                        "type": type.rawValue,
                    ]
                )
            }
        }
    }
}

struct Analytics {
    enum FeatureTrackingType: String {
        case game = "Game"
        case auto = "Auto Tuning"
        case dp = "Driver Practice"
        case ep = "Endgame Practice"
        case hna = "History & Analysis"
        case timer = "Timer"
        case calc = "Calculator"
    }

    enum ElementsTrackingType: String {
        case game = "Game"
        case auto = "Auto Tuning"
        case dp = "Driver Practice"
        case ep = "Endgame Practice"
    }
}
