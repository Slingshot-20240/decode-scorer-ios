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
    @AppStorage("preserveTeamsAfterResetting") private
        var preserveTeamsAfterResetting: Bool = false
    @AppStorage("preserveTeamsAfterExiting") private
        var preserveTeamsAfterExiting: Bool = false

    @AppStorage("practiceModeColor") private var practiceModeColor:
        PracticeModeColor = .decodeGold

    @AppStorage("saveButtonWarningRead") private var saveButtonWarningRead:
        Bool = false

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

                    VStack(alignment: .leading, spacing: 16) {
                        SettingsLabel(
                            title: "Preserve Teams",
                            description:
                                "Keep team selections after resetting or exiting scoring mode",
                            icon: "bookmark"
                        )

                        HStack(spacing: 12) {
                            Image(systemName: "bookmark")
                                .font(.title3)
                                .opacity(0)

                            VStack(alignment: .leading, spacing: 16) {
                                Divider()
                                    .padding(.leading, 32)

                                SettingsToggle(
                                    title: "After Resetting",
                                    icon: "arrow.2.circlepath",
                                    small: true,
                                    isOn: $preserveTeamsAfterResetting
                                )

                                Divider()
                                    .padding(.leading, 32)

                                SettingsToggle(
                                    title: "After Exiting",
                                    icon: "rectangle.portrait.and.arrow.right",
                                    small: true,
                                    isOn: $preserveTeamsAfterExiting
                                )
                            }
                        }
                    }

                } header: {
                    Label("Behavior", systemImage: "rectangle.2.swap")
                } footer: {
                    Text(
                        "To select a team, long press the team selection button in the full game scoring mode."
                    )
                }
                .headerProminence(.increased)

                Section {
                    CustomSetting(
                        title: "Calculator Accent Color",
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
                    Button("Reset Warnings") {
                        Haptics.play(.light)
                        saveButtonWarningRead = false
                    }
                }

                Section {
                } header: {
                    VStack(alignment: .leading) {
                        Text("DECODE™ Scorer for FTC®")
                        Text("presented by **20240 Slingshot**")
                            .font(.subheadline)
                    }
                } footer: {
                    Text(
                        """
                        Version \(version) (\(build))

                        https://ftcscoring.app

                        [Privacy Policy](https://ftcscoring.app/privacy)

                        [Terms & Conditions](https://ftcscoring.app/terms)

                        *FIRST*®, *FIRST*® Tech Challenge, FTC®, *FIRST*® AGE™, DECODE™, and all accompanying logos as they are created, are trademarks of For Inspiration and Recognition of Science and Technology (*FIRST*®) (www.firstinspires.org). These trademarks are used by special permission of *FIRST* which is not overseeing, involved with, or responsible for this activity, product, or service. © 2025 *FIRST*®. Used by special permission. All rights reserved.

                        [Open Source Licenses](https://ftcscoring.app/foss)

                        A free and open source Slingshot Outreachware project.
                        © 2025 FTC Team 20240 Slingshot and Contributors. MIT License.
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
    let description: String?
    let icon: String?
    let small: Bool
    @Binding var isOn: Bool

    init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        small: Bool = false,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.small = small
        _isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            SettingsLabel(
                title: title,
                description: description,
                icon: icon,
                small: small
            )
        }
    }
}

struct CustomSetting<V: View>: View {
    let title: String
    let description: String?
    let icon: String?
    let small: Bool
    let viewBuilder: () -> V

    init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        small: Bool = false,
        viewBuilder: @escaping () -> V
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.small = small
        self.viewBuilder = viewBuilder
    }

    var body: some View {
        HStack(spacing: 12) {
            SettingsLabel(
                title: title,
                description: description,
                icon: icon,
                small: small
            )

            Spacer()

            viewBuilder()
        }
    }
}

struct SettingsLabel: View {
    let title: String
    let description: String?
    let icon: String?
    let small: Bool

    init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        small: Bool = false
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.small = small
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(small ? .body : .title3)
            }

            VStack(alignment: .leading) {
                Text(title)
                    .font(small ? .subheadline : .body)

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
