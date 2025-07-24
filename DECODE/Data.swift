//
//  Data.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import Foundation
import SwiftData

@Model
final class Game {
    var id: String
    var teams: GameTeams
    var scores: GameScores

    init(scores: GameScores, teams: GameTeams = .init()) {
        self.id = UUID().uuidString
        self.teams = teams
        self.scores = scores
    }
}

struct GameTeams: Codable {
    var blue: AllianceTeams
    var red: AllianceTeams

    init() {
        self.blue = .init()
        self.red = .init()
    }

    struct AllianceTeams: Codable {
        var one: String?
        var two: String?

        init() {
            self.one = nil
            self.two = nil
        }
    }
}

struct GameScores: Codable {
    var blue: AllianceScores
    var red: AllianceScores

    init() {
        self.blue = .init()
        self.red = .init()
    }

    struct AllianceScores: Codable {
        var auto: StageScores
        var teleop: StageScores
        var minorFoulsFromOtherAllianceAwarded: Int
        var majorFoulsFromOtherAllianceAwarded: Int

        init() {
            self.auto = .init()
            self.teleop = .init()
            self.minorFoulsFromOtherAllianceAwarded = 0
            self.majorFoulsFromOtherAllianceAwarded = 0
        }

        struct StageScores: Codable {
            var samplesNet: Int
            var samplesLow: Int
            var samplesHigh: Int
            var specimenLow: Int
            var specimenHigh: Int
            var team1Location: Location
            var team2Location: Location

            init() {
                self.samplesNet = 0
                self.samplesLow = 0
                self.samplesHigh = 0
                self.specimenLow = 0
                self.specimenHigh = 0
                self.team1Location = .none
                self.team2Location = .none
            }

            enum Location: String, Codable, RawRepresentable {
                case none = "None"
                case oZone = "Observation Zone"
                case aZone = "Ascent Zone"
                case l2 = "Level 2"
                case l3 = "Level 3"

                var autoDescription: String {
                    self.rawValue
                }

                var teleopDescription: String {
                    switch self {
                    case .oZone:
                        "O-Zone"
                    case .aZone:
                        "Level 1"
                    default:
                        self.rawValue
                    }
                }

                func description(_ stage: ScoringStage) -> String {
                    switch stage {
                    case .auto:
                        return self.autoDescription
                    case .teleop:
                        return self.teleopDescription
                    }
                }

                var icon: String {
                    switch self {
                    case .none:
                        "nosign"
                    case .oZone:
                        "eyeglasses"
                    case .aZone:
                        "hexagon.bottomhalf.filled"
                    case .l2:
                        "chevron.compact.up"
                    case .l3:
                        "chevron.up"
                    }
                }

                var points: Int {
                    switch self {
                    case .none:
                        0
                    case .oZone:
                        3
                    case .aZone:
                        3
                    case .l2:
                        15
                    case .l3:
                        30
                    }
                }
            }

            var total: Int {
                return self.samplesNet * 2
                    + self.samplesLow * 4
                    + self.samplesHigh * 8
                    + self.specimenLow * 6
                    + self.specimenHigh * 10
                    + self.team1Location.points
                    + self.team2Location.points
            }
        }

        var total: Int {
            return self.auto.total + self.teleop.total
                + self.minorFoulsFromOtherAllianceAwarded * 5
                + self.majorFoulsFromOtherAllianceAwarded * 15
        }
    }

    var total: Int {
        return self.blue.total + self.red.total
    }
}

enum ScoringStage: String, Hashable, CaseIterable, RawRepresentable {
    case auto = "Auto"
    case teleop = "Teleop"

    var timerStartStage: GameTimer.Stage {
        switch self {
        case .auto:
            .start
        case .teleop:
            .teleopJumpStart
        }
    }
}
