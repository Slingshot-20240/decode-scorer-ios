//
//  MaxArea.swift
//  DECODE
//
//  Created by Jining Liu on 7/23/25.
//

import SwiftUI

struct MaxAreaViewModifier: ViewModifier {
    let alignment: Alignment
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

extension View {
    func maxArea(alignment: Alignment = .center) -> some View {
        modifier(MaxAreaViewModifier(alignment: alignment))
    }
}
