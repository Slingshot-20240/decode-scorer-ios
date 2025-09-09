//
//  GlassBackground.swift
//  DECODE
//
//  Created by Jining Liu on 9/9/25.
//

import SwiftUI

struct GlassBackground: ViewModifier {
    let shape: any Shape

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(in: shape)
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(AnyShape(shape))
        }
    }
}

extension View {
    func glassBackground(shape: any Shape = Capsule()) -> some View {
        modifier(GlassBackground(shape: shape))
    }
}
