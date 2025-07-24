//
//  CornerRadius.swift
//  DECODE
//
//  Created by Jining Liu on 7/21/25.
//

import SwiftUI

struct CornerRadiusViewModifier: ViewModifier {
    let radius: CGFloat
    let corners: Set<Corner>

    enum Corner: CaseIterable {
        case topLeading, bottomLeading, bottomTrailing, topTrailing
    }

    func body(content: Content) -> some View {
        content
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: corners.contains(.topLeading)
                        ? radius : 0,
                    bottomLeadingRadius: corners.contains(.bottomLeading)
                        ? radius : 0,
                    bottomTrailingRadius: corners.contains(.bottomTrailing)
                        ? radius : 0,
                    topTrailingRadius: corners.contains(.topTrailing)
                        ? radius : 0,
                    style: .continuous
                )
            )
    }
}

extension View {
    func radius(
        _ radius: CGFloat,
        corners: Set<CornerRadiusViewModifier.Corner> = Set(
            CornerRadiusViewModifier.Corner.allCases
        )
    ) -> some View {
        modifier(CornerRadiusViewModifier(radius: radius, corners: corners))
    }

    func useDeviceCornerRadius(
        _ corners: Set<CornerRadiusViewModifier.Corner>,
        min: CGFloat = 20,
        fallback: CGFloat = 24,
        subtract: CGFloat = 0
    ) -> some View {
        modifier(
            CornerRadiusViewModifier(
                radius: (UIScreen.main.displayCornerRadius(min: min)
                    ?? (fallback + subtract)) - subtract,
                corners: corners
            )
        )
    }
}
