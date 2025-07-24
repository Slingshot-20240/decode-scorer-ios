//
//  ColorInvert.swift
//  DECODE
//
//  Created by Jining Liu on 7/21/25.
//

import SwiftUI

struct ColorInvertViewModifier: ViewModifier {
    let inverted: Bool

    func body(content: Content) -> some View {
        if inverted {
            content
                .colorInvert()
        } else {
            content
        }
    }
}

extension View {
    func colorInvert(_ inverted: Bool) -> some View {
        modifier(ColorInvertViewModifier(inverted: inverted))
    }
}
