//
//  DriverPracticeColor.swift
//  DECODE
//
//  Created by Jining Liu on 9/11/25.
//

import SwiftUI

enum DriverPracticeColor: String, Codable, Hashable, CaseIterable,
    RawRepresentable
{
    case red = "Red"
    case blue = "Blue"

    var color: Color {
        switch self {
        case .red:
            return .firstRed
        case .blue:
            return .firstBlue
        }
    }
}
