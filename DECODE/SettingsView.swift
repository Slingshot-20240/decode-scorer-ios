//
//  SettingsView.swift
//  DECODE
//
//  Created by Jining Liu on 9/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @AppStorage("nfMode") private var nfMode: Bool = false
    @AppStorage("flipAlliances") private var flipAlliances: Bool = false
    @AppStorage("preserveTeams") private var preserveTeams: Bool = false

    @AppStorage("practiceModeColor") private var practiceModeColor:
        PracticeModeColor = .decodeGold

    var body: some View {
        NavigationStack {
            List {
                Section {
                } header: {
                    if let warningLabel = DECODE.environment.warningLabel {
                        warningLabel
                    }
                }
                .font(.subheadline)
                .headerProminence(.increased)

                Section {
                    SettingsToggle(
                        title: "NF (NP) Mode",
                        description:
                            "Exclude foul (penalty) points from the total score",
                        icon: "flag.slash",
                        isOn: $nfMode
                    )

                    SettingsToggle(
                        title: "Flip Alliances",
                        description:
                            "Swap alliances to have blue on the left and red on the right",
                        icon: "arrow.left.arrow.right",
                        isOn: $flipAlliances
                    )

                    SettingsToggle(
                        title: "Preserve Teams",
                        description:
                            "Keep team selections after resetting or exiting scoring mode",
                        icon: "bookmark",
                        isOn: $preserveTeams
                    )
                } header: {
                    Label("Behavior", systemImage: "rectangle.2.swap")
                }
                .headerProminence(.increased)

                Section {
                    CustomSetting(
                        title: "Calculator Theme Color",
                        icon: "paintpalette"
                    ) {
                        ForEach(PracticeModeColor.allCases, id: \.self) {
                            color in
                            Button {
                                Haptics.play(.light)
                                practiceModeColor = color
                            } label: {
                                Circle()
                                    .fill(color.color.gradient)
                                    .frame(width: 24)
                                    .overlay {
                                        if practiceModeColor == color {
                                            Image(systemName: "checkmark")
                                                .resizable()
                                                .scaledToFit()
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                                .frame(width: 12)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .buttonBorderShape(.circle)
                        }
                    }

//                    NavigationLink(destination: appIconView) {
//                        SettingsLabel(title: "App Icon", icon: "app")
//                    }
                } header: {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .headerProminence(.increased)

                Section {
                } header: {
                    VStack(alignment: .leading) {
                        Text("DECODE™ Scorer for FTC")
                        Text("presented by **20240 Slingshot**")
                            .font(.subheadline)
                    }
                } footer: {
                    Text(
                        """
                        Version \(version) (\(build))

                        https://ftcscoring.app

                        [Privacy Policy](https://ftcscoring.app/privacy)

                        Team data provided by the [FTC API](https://ftc-events.firstinspires.org/services/API).

                        *FIRST*®, *FIRST*® Tech Challenge, FTC®, *FIRST*® AGE™, DECODE™, and all accompanying logos as they are created, are trademarks of For Inspiration and Recognition of Science and Technology (*FIRST*®) (www.firstinspires.org). These trademarks are used by special permission of *FIRST* which is not overseeing, involved with, or responsible for this activity, product, or service. © 2025 *FIRST*®. Used by special permission. All rights reserved.

                        [Open Source Licenses](https://ftcscoring.app/foss)

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

    var appIconView: some View {
        Text("Coming Soon...")
            .navigationTitle("App Icon")
    }
}

struct SettingsToggle: View {
    let title: String
    let description: String
    let icon: String?
    @Binding var isOn: Bool

    init(
        title: String,
        description: String,
        icon: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        _isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            SettingsLabel(title: title, description: description, icon: icon)
        }
    }
}

struct CustomSetting<V: View>: View {
    let title: String
    let description: String?
    let icon: String?
    let viewBuilder: () -> V

    init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        viewBuilder: @escaping () -> V
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.viewBuilder = viewBuilder
    }

    var body: some View {
        HStack(spacing: 12) {
            SettingsLabel(title: title, description: description, icon: icon)

            Spacer()

            viewBuilder()
        }
    }
}

struct SettingsLabel: View {
    let title: String
    let description: String?
    let icon: String?

    init(
        title: String,
        description: String? = nil,
        icon: String? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.title3)
            }

            VStack(alignment: .leading) {
                Text(title)
                if let description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
