//
//  ContentView.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var wrappedGames: [GameDataWrapper]

    var body: some View {
        GeometryReader { proxy in
            Label("DECODE™", systemImage: "rectangle.and.text.magnifyingglass")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.accent)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameDataWrapper.self, inMemory: true)
}
