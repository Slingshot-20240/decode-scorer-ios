//
//  SettingsView.swift
//  DECODE
//
//  Created by Jining Liu on 9/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Coming Soon...")
                } header: {
                    Label("Behavior", systemImage: "rectangle.2.swap")
                }
                .headerProminence(.increased)

                Section {
                    Text("Coming Soon...")
                } header: {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .headerProminence(.increased)

                Section {
                } header: {
                    VStack(alignment: .leading) {
                        Text("DECODE™ Scorer for FTC")
                        Text("presented by 20240 Slingshot")
                            .font(.subheadline)
                    }
                } footer: {
                    Text(
                        """
                        Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Build"))

                        Team data provided by the [FTC API](https://ftc-events.firstinspires.org/services/API).

                        *FIRST*®, *FIRST*® Tech Challenge, FTC®, *FIRST*® AGE™, DECODE™, and all accompanying logos as they are created, are trademarks of For Inspiration and Recognition of Science and Technology (*FIRST*®) (www.firstinspires.org). These trademarks are used by special permission of *FIRST* which is not overseeing, involved with, or responsible for this activity, product, or service. © 2025 *FIRST*®. Used by special permission. All rights reserved.

                        © 2025 FTC Team 20240 Slingshot and contributors.
                        Licensed under the MIT License.

                        """
                    )
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
