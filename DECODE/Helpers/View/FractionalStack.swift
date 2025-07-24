//
//  FractionalStack.swift
//  DECODE
//
//  Created by Jining Liu on 7/19/25.
//

import SwiftUI

struct FractionalStack: View {
    let direction: Direction
    let divisions: Int
    let elements: Int
    let spacing: CGFloat
    let content: (FractionalDistance) -> AnyView

    @State private var fractionalDistance: FractionalDistance?

    init(
        _ direction: Direction,
        divisions: Int,
        elements: Int? = nil,
        spacing: CGFloat = 0,
        @ViewBuilder content: @escaping (FractionalDistance) -> some View
    ) {
        self.direction = direction
        self.divisions = divisions
        self.elements = elements ?? divisions
        self.spacing = spacing
        self.content = { fd in AnyView(content(fd)) }
        self.fractionalDistance = nil
    }

    enum Direction {
        case vertical, horizontal
    }

    struct FractionalDistance {
        let total: CGFloat
        let divisions: Int
        let elements: Int
        let spacing: CGFloat

        func divs(_ div: Int) -> CGFloat {
            let divisions = CGFloat(divisions)
            let elements = CGFloat(elements)
            let div = CGFloat(div)

            return (total - (elements - 1) * spacing)
                / divisions * div
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let fd = fractionalDistance {
                    switch direction {
                    case .vertical:
                        VStack(spacing: spacing) {
                            content(fd)
                        }
                    case .horizontal:
                        HStack(spacing: spacing) {
                            content(fd)
                        }
                    }
                }
            }
            .onAppear {
                fractionalDistance = FractionalDistance(
                    total:
                        direction == .horizontal
                        ? proxy.size.width
                        : proxy.size.height,
                    divisions: divisions,
                    elements: elements,
                    spacing: spacing
                )
            }
        }
    }
}

#Preview {
    FractionalStack(.vertical, divisions: 4, elements: 3, spacing: 0) { fd in
        Color.red
            .frame(height: fd.divs(1))
        Color.green
            .frame(height: fd.divs(2))
        Color.blue
            .frame(height: fd.divs(1))
    }
}
