//
//  DECODEApp.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import Aptabase
import SwiFTC
import SwiftData
import SwiftUI

let version: String =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    ?? "Unknown Version"
let build: String =
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Build"
let environment: AppEnvironment = .alpha

enum AppEnvironment {
    case production
    case beta
    case alpha
    case development

    var warningLabel: (some View)? {
        switch self {
        case .beta:
            Label(
                "Beta software. Features may be unstable. Use with caution.",
                systemImage: "testtube.2"
            )
            .foregroundStyle(.orange)
        case .alpha:
            Label(
                "Alpha software. For internal testing only. \nDistribution without permission is prohibited.",
                systemImage: "hand.raised.fill"
            )
            .foregroundStyle(.red)
        case .development:
            Label(
                "Development build. For development purposes only. \nDistribution without permission is prohibited.",
                systemImage: "hammer.fill"
            )
            .foregroundStyle(.indigo)
        default:
            nil
        }
    }
}

@main
struct DECODEApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DecodeGameModel.self
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

    init() {
        Analytics.shared.launch()
    }

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
