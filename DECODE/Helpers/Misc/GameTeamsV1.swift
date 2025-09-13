//
//  GameTeamsV1.swift
//  DECODE
//
//  Created by Jining Liu on 9/12/25.
//

import Foundation
import SwiFTC

extension GameTeamsV1: @retroactive RawRepresentable {
    public var rawValue: String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self),
            let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let value = try? JSONDecoder().decode(GameTeamsV1.self, from: data)
        else {
            return nil
        }
        self = value
    }
}
