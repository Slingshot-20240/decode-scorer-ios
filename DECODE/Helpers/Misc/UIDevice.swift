//
//  UIDevice.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftUI

extension UIDevice {
    var isPhone: Bool { self.userInterfaceIdiom == .phone }
    var isPad: Bool { self.userInterfaceIdiom == .pad }
}
