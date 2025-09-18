//
//  CalculatorView.swift
//  DECODE
//
//  Created by Jining Liu on 9/13/25.
//

import SwiFTC
import SwiftUI

struct CalculatorView: View {
    @Environment(\.dismiss) var dismiss

    @State private var scores: DecodeGameScores.AllianceScores = .init()

    @State private var scoringStage: GameScoringStageV1 = .auto
    @State private var scoringElement: ScoringElement = .classified

    @State private var batteryPercent: Float
    @State private var batteryIsCharging: Bool

    @State private var showSettings: Bool = false

    @StateObject private var orientation: OrientationManager = UIApplication
        .orientation

    @AppStorage("nfMode") private var nfMode: Bool = false

    @AppStorage("practiceModeColor") private var practiceModeColor:
        PracticeModeColor = .decodeGold

    init() {
        self.batteryPercent = UIDevice.current.batteryLevel * 100
        self.batteryIsCharging = UIDevice.current.batteryState == .charging
    }

    var body: some View {
        VStack {
            topBar

            FractionalStack(.horizontal, divisions: 13, elements: 2, spacing: 8)
            { fdh in
                HStack(spacing: 8) {
                    VStack(spacing: 8) {
                        SelectorItem(
                            icon: "tray.full",
                            name: "Classified",
                            element: .classified,
                            scoringElement: $scoringElement
                        )

                        SelectorItem(
                            icon: "arrowshape.bounce.forward",
                            name: "Overflown",
                            element: .overflown,
                            scoringElement: $scoringElement
                        )

                        SelectorItem(
                            icon: "righttriangle",
                            name: "Depot",
                            element: .depot,
                            scoringElement: $scoringElement
                        )
                        .foregroundStyle(
                            scoringStage == .auto ? .secondary : .primary
                        )
                        .opacity(scoringStage == .auto ? 0.4 : 1)
                        .disabled(scoringStage == .auto)

                        SelectorItem(
                            icon: "swatchpalette",
                            name: "Motifs",
                            element: .motifs,
                            scoringElement: $scoringElement
                        )

                        SelectorItem(
                            icon: "location.fill.viewfinder",
                            name: "Location",
                            element: .location,
                            scoringElement: $scoringElement
                        )

                        SelectorItem(
                            icon: "flag",
                            name: "Fouls",
                            element: .fouls,
                            scoringElement: $scoringElement
                        )
                    }

                    VStack(spacing: 8) {
                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("\(scores.auto.classfied)")
                                    .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .classified
                                        && scoringStage == .auto
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .classified
                                    && scoringStage == .auto
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .auto {
                                    Haptics.play(.light)
                                }
                                scoringStage = .auto
                                scoringElement = .classified
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("\(scores.auto.overflown)")
                                    .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .overflown
                                        && scoringStage == .auto
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .overflown
                                    && scoringStage == .auto
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .auto {
                                    Haptics.play(.light)
                                }
                                scoringStage = .auto
                                scoringElement = .overflown
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("-")
                                    .fontWeight(.regular)
                                    .contentTransition(.numericText())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                            .radius(12)
                            .opacity(scoringStage == .auto ? 0.4 : 1)
                            .disabled(scoringStage == .auto)

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text(
                                    "\(scores.auto.matchingMotifs)"
                                )
                                .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .motifs
                                        && scoringStage == .auto
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .motifs
                                    && scoringStage == .auto
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .auto {
                                    Haptics.play(.light)
                                }
                                scoringStage = .auto
                                scoringElement = .motifs
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Image(
                                    systemName: scores.auto.team1Location.icon
                                )
                                .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .location
                                        && scoringStage == .auto
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .location
                                    && scoringStage == .auto
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .auto {
                                    Haptics.play(.light)
                                }
                                scoringStage = .auto
                                scoringElement = .location
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text(
                                    "\(scores.minorFoulsFromOtherAllianceAwarded)"
                                )
                                .fontWeight(.regular)
                                .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                            .background(.yellow.opacity(0.2))
                            .radius(12)
                            .onTapGesture {
                                Haptics.play(.light)
                                scoringElement = .fouls
                            }
                    }
                    .font(.title2)
                    .fontWeight(scoringStage == .auto ? .semibold : .regular)
                    .foregroundStyle(
                        scoringStage == .auto ? .primary : .secondary
                    )

                    VStack(spacing: 8) {
                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("\(scores.teleop.classfied)")
                                    .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .classified
                                        && scoringStage == .teleop
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .classified
                                    && scoringStage == .teleop
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .teleop {
                                    Haptics.play(.light)
                                }
                                scoringStage = .teleop
                                scoringElement = .classified
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("\(scores.teleop.overflown)")
                                    .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .overflown
                                        && scoringStage == .teleop
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .overflown
                                    && scoringStage == .teleop
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .teleop {
                                    Haptics.play(.light)
                                }
                                scoringStage = .teleop
                                scoringElement = .overflown
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("\(scores.teleop.depot)")
                                    .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .depot
                                        && scoringStage == .teleop
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .depot
                                    && scoringStage == .teleop
                            )
                            .radius(12)
                            .foregroundStyle(
                                scoringStage == .auto ? .secondary : .primary
                            )
                            .opacity(scoringStage == .auto ? 0.4 : 1)
                            .disabled(scoringStage == .auto)
                            .onTapGesture {
                                if scoringStage == .teleop {
                                    Haptics.play(.light)
                                }
                                scoringStage = .teleop
                                scoringElement = .depot
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text("\(scores.teleop.matchingMotifs)")
                                    .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .motifs
                                        && scoringStage == .teleop
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .motifs
                                    && scoringStage == .teleop
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .teleop {
                                    Haptics.play(.light)
                                }
                                scoringStage = .teleop
                                scoringElement = .motifs
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Image(
                                    systemName:
                                        "\(scores.teleop.team1Location.icon)"
                                )
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(
                                Rectangle().fill(
                                    (scoringElement == .location
                                        && scoringStage == .teleop
                                        ? Color.primary : .clear).gradient
                                )
                                .colorInvert()
                            )
                            .background(.ultraThinMaterial)
                            .colorInvert(
                                scoringElement == .location
                                    && scoringStage == .teleop
                            )
                            .radius(12)
                            .onTapGesture {
                                if scoringStage == .teleop {
                                    Haptics.play(.light)
                                }
                                scoringStage = .teleop
                                scoringElement = .location
                            }

                        Text("00")
                            .fontWeight(.semibold)
                            .opacity(0)
                            .overlay {
                                Text(
                                    "\(scores.majorFoulsFromOtherAllianceAwarded)"
                                )
                                .fontWeight(.regular)
                                .contentTransition(.numericText())
                            }
                            .padding(8)
                            .frame(maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                            .background(.red.opacity(0.2))
                            .radius(12)
                            .onTapGesture {
                                Haptics.play(.light)
                                scoringElement = .fouls
                            }
                    }
                    .font(.title2)
                    .fontWeight(scoringStage == .teleop ? .semibold : .regular)
                    .foregroundStyle(
                        scoringStage == .teleop ? .primary : .secondary
                    )
                }

                FractionalStack(
                    .vertical,
                    divisions: 8,
                    elements: 2,
                    spacing: 8
                ) { fdv in
                    Text("\(scores.total(excludeFouls: nfMode))")
                        .font(.system(size: 144, weight: .semibold))
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                        .foregroundStyle(.white)
                        .padding(24)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                        .background(practiceModeColor.color.gradient)
                        .radius(32)

                    HStack(spacing: 8) {
                        switch scoringElement {
                        case .location:
                            FractionalStack(
                                .horizontal,
                                divisions: 3,
                                elements: 2,
                                spacing: 8
                            ) { fd in
                                switch scoringStage {
                                case .auto:
                                    let locationButtons = AutoLocationButtons(
                                        binding: $scores.auto.team1Location,
                                        scoringStage: scoringStage
                                    )

                                    locationButtons.left
                                        .frame(width: fd.divs(2))

                                    locationButtons.none
                                        .frame(width: fd.divs(1))
                                        .useDeviceCornerRadius(
                                            [.bottomTrailing],
                                            min: 24,
                                            fallback: 8,
                                            subtract: 16
                                        )
                                case .teleop:
                                    let locationButtons = TeleopLocationButtons(
                                        binding: $scores.teleop.team1Location,
                                        scoringStage: scoringStage
                                    )

                                    HStack(spacing: 8) {
                                        VStack(spacing: 8) {
                                            locationButtons.partial
                                            locationButtons.full
                                        }
                                    }
                                    .frame(width: fd.divs(2))

                                    locationButtons.none
                                        .frame(width: fd.divs(1))
                                        .useDeviceCornerRadius(
                                            [.bottomTrailing],
                                            min: 24,
                                            fallback: 8,
                                            subtract: 16
                                        )
                                }
                            }
                            .padding(8)
                        case .fouls:
                            Spacer()

                            FoulButtons(
                                icon: "exclamationmark",
                                color: .yellow,
                                width: fdh.divs(1),
                                fouls: $scores
                                    .minorFoulsFromOtherAllianceAwarded
                            )
                            .padding([.vertical, .leading], 8)

                            Spacer()

                            FoulButtons(
                                icon: "exclamationmark.3",
                                color: .red,
                                width: fdh.divs(1),
                                fouls: $scores
                                    .majorFoulsFromOtherAllianceAwarded
                            )
                            .padding([.vertical, .trailing], 8)

                            Spacer()
                        default:
                            let binding = scoringElementBindings()

                            ScoreButtons(
                                value: binding,
                                width: fdh.divs(1),
                                max: scoringElement == .motifs ? 9 : 99
                            )
                            .padding([.vertical, .leading], 8)

                            WheelPicker(
                                value: binding,
                                max: scoringElement == .motifs ? 9 : 99
                            )
                            .padding(.trailing, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: fdv.divs(3))
                    .background(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            colors: [practiceModeColor.color, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ).opacity(0.25)
                    )
                    .radius(16)
                }
                .frame(maxWidth: fdh.divs(4), maxHeight: .infinity)
            }
            .animation(.smooth, value: scores.total(excludeFouls: nfMode))
        }
        .useDeviceCornerRadius(
            [
                orientation.direction == .left
                    ? .bottomTrailing : .bottomLeading
            ],
            fallback: 16,
            subtract: 8
        )
        .fullScreenPadding()
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
        }
        .onChange(of: scoringStage) { _, stage in
            if stage == .auto && scoringElement == .depot {
                scoringElement = .classified
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.batteryLevelDidChangeNotification
            )
        ) { _ in
            batteryPercent = UIDevice.current.batteryLevel * 100
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.batteryStateDidChangeNotification
            )
        ) { _ in
            batteryIsCharging = UIDevice.current.batteryState == .charging
        }
    }

    func scoringElementBindings() -> Binding<Int> {
        func scoringStageBindingsSelector(
            _ auto: Binding<Int>,
            _ teleop: Binding<Int>
        ) -> Binding<Int> {
            switch scoringStage {
            case .auto:
                return auto
            case .teleop:
                return teleop
            }
        }

        var scoringElementBindings: Binding<Int> {
            switch scoringElement {
            case .classified:
                return scoringStageBindingsSelector(
                    $scores.auto.classfied,
                    $scores.teleop.classfied
                )
            case .overflown:
                return scoringStageBindingsSelector(
                    $scores.auto.overflown,
                    $scores.teleop.overflown,
                )
            case .depot:
                return scoringStageBindingsSelector(
                    .constant(0),
                    $scores.teleop.depot,
                )
            case .motifs:
                return scoringStageBindingsSelector(
                    $scores.auto.matchingMotifs,
                    $scores.teleop.matchingMotifs,
                )
            default:
                return .constant(0)
            }
        }

        return scoringElementBindings
    }

    var topBar: some View {
        HStack(spacing: 16) {
            Menu("", systemImage: "line.3.horizontal") {
                ControlGroup {
                    Button("Reset", systemImage: "arrow.2.circlepath") {
                        scores = .init()
                        scoringStage = .auto
                        scoringElement = .classified
                    }
                }

                Button("Settings", systemImage: "gear") {
                    showSettings = true
                }

                Divider()

                Button(
                    "Exit",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    role: .destructive
                ) {
                    dismiss()
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)

            HStack {
                Picker(selection: $scoringStage) {
                    ForEach(GameScoringStageV1.allCases, id: \.rawValue) {
                        stage in
                        Text(stage.rawValue)
                            .tag(stage)
                    }
                } label: {
                }
                .pickerStyle(.segmented)
                .onChange(of: scoringStage) { _, stage in
                    Haptics.play(.light)
                }
            }
            .fixedSize()

            Spacer()

            if UIDevice.current.isPhone {
                Text(.now, style: .time)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                var batterySymbol: String {
                    if batteryPercent >= 90 || batteryIsCharging {
                        return "100"
                    }

                    if batteryPercent >= 70 {
                        return "75"
                    }

                    if batteryPercent >= 40 {
                        return "50"
                    }

                    if batteryPercent >= 20 {
                        return "25"
                    }

                    return "0"
                }

                Label(
                    "\(batteryPercent, specifier: "%.0f")%",
                    systemImage:
                        "battery.\(batterySymbol)percent\(batteryIsCharging ? ".bolt" : "")"
                )
                .symbolRenderingMode(
                    batteryIsCharging ? .multicolor : .hierarchical
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    (batteryPercent < 20 && !batteryIsCharging)
                        ? .red : .primary
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(
            .leading,
            max(
                0,
                orientation.direction == .right
                    ? SafeArea.shared.rectangularLeading - 8 : 0
            )
        )
        .padding(.trailing, SafeArea.shared.rectangularTrailing - 8)
    }
}

#Preview {
    CalculatorView()
}
