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
#if targetEnvironment(simulator)
    let environment: AppEnvironment = .development
#else
    let environment: AppEnvironment = .production
#endif

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
                "Alpha software. For internal testing only.\nDistribution without permission is prohibited.",
                systemImage: "hand.raised.fill"
            )
            .foregroundStyle(.red)
        case .development:
            Label(
                "Development build. Distribution without permission is prohibited.",
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

    @State private var eventSheet: EventSheet? = nil

    @AppStorage("updatingFrom") private var updatingFrom: Int = 0

    @AppStorage("preserveTeamsAfterResetting") private
        var preserveTeamsAfterResetting: Bool = false
    @AppStorage("preserveTeamsAfterExiting") private
        var preserveTeamsAfterExiting: Bool = false

    init() {
        Analytics.shared.launch()
        UIDevice.current.isBatteryMonitoringEnabled = true

        let build = Int(build) ?? 0
        if updatingFrom < build {
            if updatingFrom < 15 {
                let preserve = UserDefaults.standard.bool(
                    forKey: "preserveTeams"
                )
                preserveTeamsAfterResetting = preserve
                preserveTeamsAfterExiting = preserve
            }

            updatingFrom = build
        }
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
                            UIApplication.orientation.update()
                            SafeArea.shared.update(proxy)
                        }
                        .onReceive(
                            NotificationCenter.default.publisher(
                                for: UIDevice.orientationDidChangeNotification
                            )
                        ) { _ in
                            if UIDevice.current.orientation.isLandscape {
                                UIApplication.orientation.update()
                                SafeArea.shared.update(proxy)
                            }
                        }
                }
            }
            .sheet(isPresented: .constant(eventSheet == .kickoff)) {
                eventSheet = nil
            } content: {
                KickoffEventView(eventSheet: $eventSheet)
            }
            .onOpenURL { url in
                if url.scheme == "decode-scorer" {
                    eventSheet = EventSheet(
                        rawValue: url.absoluteString.replacing(
                            "decode-scorer://",
                            with: ""
                        )
                    )
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
