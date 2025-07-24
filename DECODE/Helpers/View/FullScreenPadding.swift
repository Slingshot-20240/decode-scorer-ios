//
//  FullScreenPadding.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftUI

struct FullScreenPadding: ViewModifier {

    let rectangular: Bool

    func body(content: Content) -> some View {
        var padSpecificPadding: CGFloat {
            if #available(iOS 26.0, *) {
                24
            } else {
                22
            }
        }

        content
            .padding(
                .top,
                UIDevice.current.isPhone ? SafeArea.shared.top.min(8) : 0
            )
            .padding(
                .leading,
                UIDevice.current.isPhone
                    ? (rectangular && UIApplication.shared.orientedRight
                        ? SafeArea.shared.rectangularLeading
                        : SafeArea.shared.leading.min(8)) : 8
            )
            .padding(
                .trailing,
                UIDevice.current.isPhone
                    ? (rectangular && UIApplication.shared.orientedLeft
                        ? SafeArea.shared.rectangularTrailing
                        : SafeArea.shared.trailing.min(8)) : 8
            )
            .padding(.bottom, 8)
            .padding(.top, UIDevice.current.isPad ? padSpecificPadding : 0)
            .ignoresSafeArea()
    }
}

extension View {
    func fullScreenPadding(rectangular: Bool = false) -> some View {
        modifier(FullScreenPadding(rectangular: rectangular))
    }
}
