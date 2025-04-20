//
//  CGFloat.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import Foundation

extension CGFloat {
    func min(_ value: CGFloat) -> CGFloat {
        return CGFloat.maximum(value, self)
    }
}
