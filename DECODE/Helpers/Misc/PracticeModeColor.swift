//
//  PracticeModeColor.swift
//  DECODE
//
//  Created by Jining Liu on 9/11/25.
//

import SwiftUI

enum PracticeModeColor: String, Codable, Hashable, CaseIterable,
    RawRepresentable
{
    case decodeGold = "DECODE Gold"
    case decodeOrange = "DECODE Orange"
    case decodeGreen = "DECODE Green"
    case decodeBlue = "DECODE Blue"
    case firstRed = "FIRST Red"
    case firstBlue = "FIRST Blue"
    case slingshotPurple = "Slingshot Purple"

    var color: Color {
        switch self {
        case .decodeGold:
            .decodeGold
        case .decodeOrange:
            .decodeOrange
        case .decodeGreen:
            .decodeGreen
        case .decodeBlue:
            .decodeBlue
        case .firstRed:
            .firstRed
        case .firstBlue:
            .firstBlue
        case .slingshotPurple:
            .slingshotPurple
        }
    }
}
