//
//  Analytics.swift
//  DECODE
//
//  Created by Jining Liu on 9/9/25.
//

import Aptabase
import SwiFTC
import SwiftUI

struct Analytics {
    @AppStorage("gamesTracked") var gamesTracked: Int = 0
    @AppStorage("autoSessionsTracked") var autoSessionsTracked: Int = 0
    @AppStorage("dpSessionsTracked") var dpSessionsTracked: Int = 0
    @AppStorage("epSessionsTracked") var epSessionsTracked: Int = 0
    @AppStorage("calcSessionsTracked") var calcSessionsTracked: Int = 0

    @AppStorage("classifiedArtifactsTracked") var classifiedArtifactsTracked:
        Int = 0
    @AppStorage("overflownArtifactsTracked") var overflownArtifactsTracked:
        Int = 0
    @AppStorage("depotArtifactsTracked") var depotArtifactsTracked: Int = 0
    @AppStorage("totalArtifactsTracked") var totalArtifactsTracked: Int = 0

    @AppStorage("motifsTracked") var motifsTracked: Int = 0

    @AppStorage("pointsTracked") var pointsTracked: Int = 0

    static var shared = Analytics()

    func launch() {
        if !APTABASE_APP_KEY.isEmpty {
            Aptabase.shared.initialize(appKey: APTABASE_APP_KEY)
            Aptabase.shared.trackEvent("launch")
        }
    }

    func trackFeature(_ type: FeatureTrackingType) {
        Aptabase.shared.trackEvent("feature", with: ["feature": type.rawValue])
    }

    func trackCompletion(
        _ scores: DecodeGameScores,
        from type: Analytics.ElementsTrackingType
    ) {
        switch type {
        case .game:
            self.gamesTracked += 1
        case .auto:
            self.autoSessionsTracked += 1
        case .dp:
            self.dpSessionsTracked += 1
        case .ep:
            self.epSessionsTracked += 1
        case .calc:
            self.calcSessionsTracked += 1
        }

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
            self.classifiedArtifactsTracked += classified
            self.overflownArtifactsTracked += overflown
            self.depotArtifactsTracked += depot
            self.totalArtifactsTracked += artifacts

            self.motifsTracked += motifs

            if !APTABASE_APP_KEY.isEmpty {
                Aptabase.shared.trackEvent(
                    "completion",
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

        self.trackPoints(scores, from: type)
    }

    func trackPoints(
        _ scores: DecodeGameScores,
        from type: Analytics.ElementsTrackingType
    ) {
        self.pointsTracked += scores.total

        if !APTABASE_APP_KEY.isEmpty {
            if scores.total > 0 {
                Aptabase.shared.trackEvent(
                    "points",
                    with: [
                        "red": scores.red.total,
                        "blue": scores.blue.total,
                        "combined": scores.total,
                        "type": type.rawValue,
                    ]
                )
            }
        }
    }

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
        case calc = "Calculator"
    }
}
