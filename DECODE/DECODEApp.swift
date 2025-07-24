//
//  DECODEApp.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftData
import SwiftUI

@main
struct DECODEApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Game.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {

                if SafeArea.shared.initialized {
                    ContentView()
                }

                GeometryReader { proxy in
                    Color.clear
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        .onAppear {
                            SafeArea.shared.update(proxy)
                        }
                        .onReceive(
                            NotificationCenter.default.publisher(
                                for: UIDevice.orientationDidChangeNotification
                            )
                        ) { _ in
                            if UIDevice.current.orientation.isLandscape {
                                SafeArea.shared.update(proxy)
                            }
                        }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
