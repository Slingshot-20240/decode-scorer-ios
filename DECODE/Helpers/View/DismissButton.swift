//
//  DismissButton.swift
//  DECODE
//
//  Created by Jining Liu on 9/9/25.
//

import SwiftUI

struct DismissButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if #available(iOS 26.0, *) {
                Image(systemName: "xmark")
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
