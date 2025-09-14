//
//  DriverPracticeView.swift
//  DECODE
//
//  Created by Jining Liu on 9/13/25.
//

import SwiftUI

struct DriverPracticeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Coming Soon...")
            Button("Dismiss") {
                dismiss()
            }
        }
    }
}

#Preview {
    DriverPracticeView()
}
