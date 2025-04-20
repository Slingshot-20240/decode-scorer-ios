//
//  SafeArea.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftUI

@Observable
class SafeArea {
    
    static var shared = SafeArea()
    
    var initialized: Bool = false
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    var leading: CGFloat = 0
    var rectangularLeading: CGFloat = 0
    var trailing: CGFloat = 0
    var rectangularTrailing: CGFloat = 0
    var deviceRadius: CGFloat = 0
    
    func update(_ proxy: GeometryProxy) {
        self.top = proxy.safeAreaInsets.top
        self.bottom = proxy.safeAreaInsets.bottom
        if UIApplication.shared.orientedLeft {
            self.leading = proxy.safeAreaInsets.leading
            self.trailing = 8
            self.rectangularTrailing = proxy.safeAreaInsets.trailing > 8 ? proxy.safeAreaInsets.trailing / 2 : 8
        } else if UIApplication.shared.orientedRight {
            self.leading = 8
            self.rectangularLeading = proxy.safeAreaInsets.leading > 8 ? proxy.safeAreaInsets.leading / 2 : 8
            self.trailing = proxy.safeAreaInsets.trailing
        }
        self.deviceRadius = UIScreen.main.value(forKey: "displayCornerRadius") as? CGFloat ?? 0
        self.initialized = true
    }
}
