//
//  GameScoreView.swift
//  DECODE
//
//  Created by Jining Liu on 7/19/25.
//

import SwiftUI

struct GameScoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var timer: GameTimer
    @State private var scoringStage: ScoringStage = .auto
    @State private var scores: GameScores

    @State private var batteryPercent: Float
    @State private var batteryIsCharging: Bool

    init() {
        _timer = StateObject(wrappedValue: .shared)
        self.scores = .init()

        UIDevice.current.isBatteryMonitoringEnabled = true
        self.batteryPercent = UIDevice.current.batteryLevel * 100
        self.batteryIsCharging = UIDevice.current.batteryState == .charging
    }

    var body: some View {
        VStack(spacing: 8) {
            topBar

            FractionalStack(
                .vertical,
                divisions: 2,
                spacing: 8
            ) { fd in
                selector
                    .frame(height: fd.divs(1))

                scoreControls
                    .frame(height: fd.divs(1))
            }
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: (UIScreen.main.displayCornerRadius(min: 0)
                    ?? 26)
                    - 2
            )
            .stroke(
                timer.scoringStage != scoringStage
                    && ![.standby, .finished].contains(timer.timerStage)
                    ? .red : (timer.paused ? .secondary : .clear),
                style: .init(
                    lineWidth: 4,
                    lineCap: .round,
                    dash: [24],
                    dashPhase: 24
                )
            )
            .padding(-6)
        }
        .fullScreenPadding()
        .onChange(of: timer.scoringStage) { _, stage in
            if stage == .teleop {
                scores.blue.teleop = scores.blue.auto
                scores.blue.teleop.team1Location = .none
                scores.blue.teleop.team2Location = .none

                scores.red.teleop = scores.red.auto
                scores.red.teleop.team1Location = .none
                scores.red.teleop.team2Location = .none
            }

            scoringStage = stage
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

    var topBar: some View {
        HStack(spacing: 16) {
            Menu("", systemImage: "line.3.horizontal") {
                ControlGroup {
                    Button(
                        timer.paused ? "Resume" : "Pause",
                        systemImage: "\(timer.paused ? "play" : "pause").fill"
                    ) {
                        if timer.paused {
                            timer.resume()
                        } else {
                            timer.pause()
                        }
                    }
                    .disabled(!timer.inProgress)

                    Button("Reset", systemImage: "arrow.2.circlepath") {
                        timer.reset()
                        scores = .init()
                    }
                }

                Divider()

                Button("Settings", systemImage: "gear") {
                    // TODO: settings
                }

                Divider()

                Button(
                    "Exit",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    role: .destructive
                ) {
                    timer.reset()
                    dismiss()
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)

            HStack {
                Text(
                    timer.scoringStage == scoringStage
                        || [.standby, .finished].contains(timer.timerStage)
                        ? "Stage" : "Scoring for"
                )
                .font(.headline)
                .foregroundStyle(
                    timer.scoringStage == scoringStage
                        || [.standby, .finished].contains(timer.timerStage)
                        ? Color.primary : .red
                )

                Picker(selection: $scoringStage) {
                    ForEach(ScoringStage.allCases, id: \.rawValue) { stage in
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

            if timer.paused {
                Menu {
                    Button(
                        "Resume",
                        systemImage: "play.fill"
                    ) {
                        timer.resume()
                    }
                } label: {
                    Label("Paused", systemImage: "pause.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

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
        .padding(.trailing, SafeArea.shared.rectangularTrailing - 8)
    }

    @State private var scoringElement: ScoringElement = .netZone

    var selector: some View {
        FractionalStack(
            .horizontal,
            divisions: 8,
            elements: 3,
            spacing: 8
        ) { fd in
            VStack(spacing: 8) {
                SelectorItem(
                    icon: "chevron.up",
                    name: "High Basket",
                    element: .highBasket,
                    scoringElement: $scoringElement
                )

                SelectorItem(
                    icon: "chevron.down",
                    name: "Low Basket",
                    element: .lowBasket,
                    scoringElement: $scoringElement
                )

                SelectorItem(
                    icon: "righttriangle",
                    name: "Net Zone",
                    element: .netZone,
                    scoringElement: $scoringElement
                )
            }
            .frame(width: fd.divs(3))

            VStack(spacing: 8) {
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
            .frame(width: fd.divs(2))

            VStack(spacing: 8) {
                SelectorItem(
                    icon: "arrow.up.to.line.compact",
                    name: "High Chamber",
                    element: .highChamber,
                    scoringElement: $scoringElement
                )

                SelectorItem(
                    icon: "arrow.down.to.line.compact",
                    name: "Low Chamber",
                    element: .lowChamber,
                    scoringElement: $scoringElement
                )
            }
            .frame(width: fd.divs(3))
        }
    }

    @State private var selectedBlueTeam: TeamSelection = .one
    @State private var selectedRedTeam: TeamSelection = .one

    var scoreControls: some View {
        FractionalStack(.horizontal, divisions: 13, elements: 3, spacing: 8) {
            fd in
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    let team1Selected = selectedBlueTeam == .one

                    Button {
                        Haptics.play(.light)
                        if scoringElement == .location {
                            selectedBlueTeam = .one
                        }
                    } label: {
                        Text("Team 1")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(
                                Rectangle().fill(
                                    (team1Selected
                                        && scoringElement == .location
                                        ? Color.primary
                                        : .clear).gradient
                                ).colorInvert()
                            )
                            .colorInvert(
                                team1Selected && scoringElement == .location
                            )
                            .background(Color.secondary.opacity(0.1))
                            .background(
                                Color.primary.opacity(0.9).colorInvert()
                            )
                            .background(Color.secondary.opacity(0.5))
                            .clipShape(Capsule())
                    }

                    Button {
                        Haptics.play(.light)
                        if scoringElement == .location {
                            selectedBlueTeam = .two
                        }
                    } label: {
                        Text("Team 2")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(
                                Rectangle().fill(
                                    (!team1Selected
                                        && scoringElement == .location
                                        ? Color.primary
                                        : .clear).gradient
                                ).colorInvert()
                            )
                            .colorInvert(
                                !team1Selected && scoringElement == .location
                            )
                            .background(Color.secondary.opacity(0.1))
                            .background(
                                Color.primary.opacity(0.9).colorInvert()
                            )
                            .background(Color.secondary.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
                .tint(.primary)

                HStack(spacing: 8) {
                    switch scoringElement {
                    case .location:
                        FractionalStack(
                            .horizontal,
                            divisions: 11,
                            elements: 2,
                            spacing: 8
                        ) { fd in
                            let locationButtons = LocationButtons(
                                binding: blueLocationBinding(),
                                scoringStage: scoringStage
                            )

                            locationButtons.none
                                .frame(width: fd.divs(3))
                                .useDeviceCornerRadius(
                                    [.bottomLeading],
                                    min: 24,
                                    fallback: 8,
                                    subtract: 16
                                )

                            HStack(spacing: 8) {
                                VStack(spacing: 8) {
                                    locationButtons.oZone
                                    locationButtons.aZone
                                }

                                if scoringStage == .teleop {
                                    VStack(spacing: 8) {
                                        locationButtons.l2
                                        locationButtons.l3
                                    }
                                }
                            }
                            .frame(width: fd.divs(8))
                        }
                        .padding(8)
                    case .fouls:
                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark.3",
                            color: .red,
                            width: fd.divs(1),
                            fouls: $scores.red
                                .majorFoulsFromOtherAllianceAwarded
                        )
                        .padding([.vertical, .leading], 8)

                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark",
                            color: .yellow,
                            width: fd.divs(1),
                            fouls: $scores.red
                                .minorFoulsFromOtherAllianceAwarded
                        )
                        .padding([.vertical, .trailing], 8)

                        Spacer()
                    default:
                        WheelPicker(value: scoringElementBindings().blue)
                            .padding(.leading, 8)

                        ScoreButtons(
                            value: scoringElementBindings().blue,
                            width: fd.divs(1)
                        )
                        .padding([.vertical, .trailing], 8)
                    }
                }
                .maxArea()
                .background(Color.secondary.opacity(0.1))
                .background(Color.primary.opacity(0.9).colorInvert())
                .background(Color.secondary.opacity(0.5))
                .background(
                    LinearGradient(
                        colors: [.firstBlue, .clear, .clear],
                        startPoint: .bottomTrailing,
                        endPoint: .leading
                    )
                )
                .radius(16)
                .useDeviceCornerRadius(
                    [.bottomLeading],
                    fallback: 16,
                    subtract: 8
                )
            }
            .frame(width: fd.divs(4))

            FractionalStack(.vertical, divisions: 10, elements: 2, spacing: 8) {
                fd in
                HStack(spacing: 8) {
                    switch timer.timerStage {
                    case .standby:
                        GeometryReader { proxy in
                            Button {
                                Haptics.play(.light)
                                timer.timerStage = .finished
                            } label: {
                                Image(systemName: "arrow.turn.up.right")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .minimumScaleFactor(0.6)
                                    .padding(8)
                                    .frame(
                                        width: proxy.size.height,
                                        height: proxy.size.height
                                    )
                                    .aspectRatio(1, contentMode: .fit)
                                    .background(
                                        Rectangle().fill(Color.primary.gradient)
                                            .colorInvert().scaleEffect(y: -1)
                                    )
                                    .colorInvert()
                                    .radius(8)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)

                        Button {
                            Haptics.play(.light)
                            timer.start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.6)
                                .padding(8)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .background(
                                    Rectangle().fill(Color.primary.gradient)
                                        .colorInvert().scaleEffect(y: -1)
                                )
                                .colorInvert()
                                .radius(8)
                        }

                        GeometryReader { proxy in
                            Button {
                                Haptics.play(.light)
                                timer.start(mute: true)
                            } label: {
                                Image(systemName: "speaker.slash.fill")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .minimumScaleFactor(0.6)
                                    .padding(8)
                                    .frame(
                                        width: proxy.size.height,
                                        height: proxy.size.height
                                    )
                                    .aspectRatio(1, contentMode: .fit)
                                    .background(
                                        Rectangle().fill(Color.primary.gradient)
                                            .colorInvert().scaleEffect(y: -1)
                                    )
                                    .colorInvert()
                                    .radius(8)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    case .finished:
                        Button {

                        } label: {
                            Label(
                                "Save",
                                systemImage: "square.and.arrow.down.fill"
                            )
                            .font(.title2)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.6)
                            .padding(8)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity
                            )
                            .background(
                                Rectangle().fill(Color.primary.gradient)
                                    .colorInvert().scaleEffect(y: -1)
                            )
                            .colorInvert()
                            .radius(8)
                        }

                        Button {
                            Haptics.play(.light)
                            // TODO: details
                        } label: {
                            Label("Details", systemImage: "list.dash")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.6)
                                .padding(8)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .background(
                                    Rectangle().fill(Color.primary.gradient)
                                        .colorInvert().scaleEffect(y: -1)
                                )
                                .colorInvert()
                                .radius(8)
                        }
                    default:
                        Text(
                            "\(timer.countdown / 60):\(timer.countdown % 60, specifier: "%02d")"
                        )
                        .font(.system(size: 40, weight: .semibold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: timer.countdown)
                    }
                }
                .foregroundStyle(Color.primary)
                .padding(8)
                .maxArea()
                .background(
                    Rectangle().fill(
                        (timer.scoringStage != scoringStage
                            && ![.standby, .finished].contains(timer.timerStage)
                            ? Color.red
                            : (timer.paused ? .secondary : .primary))
                            .gradient
                    ).colorInvert()
                )
                .colorInvert()
                .radius(16)
                .frame(height: fd.divs(4))

                HStack(spacing: 8) {
                    Text("000")
                        .font(.system(size: 60, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(String(scores.blue.total))
                                .font(.system(size: 60, weight: .bold))
                                .minimumScaleFactor(0.6)
                                .contentTransition(.numericText())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .maxArea()
                        .background(.firstBlue.gradient)
                        .radius(16)

                    Text("000")
                        .font(.system(size: 60, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(String(scores.red.total))
                                .font(.system(size: 60, weight: .bold))
                                .minimumScaleFactor(0.6)
                                .contentTransition(.numericText())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .maxArea()
                        .background(.firstRed.gradient)
                        .radius(16)
                }
                .frame(height: fd.divs(6))
            }
            .frame(width: fd.divs(5))

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    let team1Selected = selectedRedTeam == .one

                    Button {
                        Haptics.play(.light)
                        if scoringElement == .location {
                            selectedRedTeam = .one
                        }
                    } label: {
                        Text("Team 1")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(
                                Rectangle().fill(
                                    (team1Selected
                                        && scoringElement == .location
                                        ? Color.primary
                                        : .clear).gradient
                                ).colorInvert()
                            )
                            .colorInvert(
                                team1Selected && scoringElement == .location
                            )
                            .background(Color.secondary.opacity(0.1))
                            .background(
                                Color.primary.opacity(0.9).colorInvert()
                            )
                            .background(Color.secondary.opacity(0.5))
                            .clipShape(Capsule())
                    }

                    Button {
                        Haptics.play(.light)
                        if scoringElement == .location {
                            selectedRedTeam = .two
                        }
                    } label: {
                        Text("Team 2")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(
                                Rectangle().fill(
                                    (!team1Selected
                                        && scoringElement == .location
                                        ? Color.primary
                                        : .clear).gradient
                                ).colorInvert()
                            )
                            .colorInvert(
                                !team1Selected && scoringElement == .location
                            )
                            .background(Color.secondary.opacity(0.1))
                            .background(
                                Color.primary.opacity(0.9).colorInvert()
                            )
                            .background(Color.secondary.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
                .tint(.primary)

                HStack(spacing: 8) {
                    switch scoringElement {
                    case .location:
                        FractionalStack(
                            .horizontal,
                            divisions: 11,
                            elements: 2,
                            spacing: 8
                        ) { fd in
                            let locationButtons = LocationButtons(
                                binding: redLocationBinding(),
                                scoringStage: scoringStage
                            )

                            HStack(spacing: 8) {
                                if scoringStage == .teleop {
                                    VStack(spacing: 8) {
                                        locationButtons.l2
                                        locationButtons.l3
                                    }
                                }

                                VStack(spacing: 8) {
                                    locationButtons.oZone
                                    locationButtons.aZone
                                }
                            }
                            .frame(width: fd.divs(8))

                            locationButtons.none
                                .frame(width: fd.divs(3))
                                .useDeviceCornerRadius(
                                    [.bottomTrailing],
                                    min: 24,
                                    fallback: 8,
                                    subtract: 16
                                )
                        }
                        .padding(8)
                    case .fouls:
                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark",
                            color: .yellow,
                            width: fd.divs(1),
                            fouls: $scores.blue
                                .minorFoulsFromOtherAllianceAwarded
                        )
                        .padding([.vertical, .leading], 8)

                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark.3",
                            color: .red,
                            width: fd.divs(1),
                            fouls: $scores.blue
                                .majorFoulsFromOtherAllianceAwarded
                        )
                        .padding([.vertical, .trailing], 8)

                        Spacer()
                    default:
                        ScoreButtons(
                            value: scoringElementBindings().red,
                            width: fd.divs(1)
                        )
                        .padding([.vertical, .leading], 8)

                        WheelPicker(value: scoringElementBindings().red)
                            .padding(.trailing, 8)
                    }
                }
                .maxArea()
                .background(Color.secondary.opacity(0.1))
                .background(Color.primary.opacity(0.9).colorInvert())
                .background(Color.secondary.opacity(0.5))
                .background(
                    LinearGradient(
                        colors: [.firstRed, .clear, .clear],
                        startPoint: .bottomLeading,
                        endPoint: .trailing
                    )
                )
                .radius(16)
                .useDeviceCornerRadius(
                    [.bottomTrailing],
                    fallback: 16,
                    subtract: 8
                )
            }
            .frame(width: fd.divs(4))
        }
        .animation(.smooth, value: scores.blue.total)
        .animation(.smooth, value: scores.red.total)
    }

    func scoringElementBindings() -> (blue: Binding<Int>, red: Binding<Int>) {
        func scoringStageBindingsSelector(
            _ blueAuto: Binding<Int>,
            _ blueTeleop: Binding<Int>,
            _ redAuto: Binding<Int>,
            _ redTeleop: Binding<Int>
        ) -> (Binding<Int>, Binding<Int>) {
            switch scoringStage {
            case .auto:
                return (blueAuto, redAuto)
            case .teleop:
                return (blueTeleop, redTeleop)
            }
        }

        var scoringElementBindings: (Binding<Int>, Binding<Int>) {
            switch scoringElement {
            case .netZone:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.samplesNet,
                    $scores.blue.teleop.samplesNet,
                    $scores.red.auto.samplesNet,
                    $scores.red.teleop.samplesNet
                )
            case .lowBasket:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.samplesLow,
                    $scores.blue.teleop.samplesLow,
                    $scores.red.auto.samplesLow,
                    $scores.red.teleop.samplesLow
                )
            case .highBasket:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.samplesHigh,
                    $scores.blue.teleop.samplesHigh,
                    $scores.red.auto.samplesHigh,
                    $scores.red.teleop.samplesHigh
                )
            case .lowChamber:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.specimenLow,
                    $scores.blue.teleop.specimenLow,
                    $scores.red.auto.specimenLow,
                    $scores.red.teleop.specimenLow
                )
            case .highChamber:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.specimenHigh,
                    $scores.blue.teleop.specimenHigh,
                    $scores.red.auto.specimenHigh,
                    $scores.red.teleop.specimenHigh
                )
            default:
                return (.constant(0), .constant(0))
            }
        }

        return scoringElementBindings
    }

    func blueLocationBinding() -> Binding<
        GameScores.AllianceScores.StageScores.Location
    > {
        func scoringStageBindingsSelector(
            _ auto: Binding<GameScores.AllianceScores.StageScores.Location>,
            _ teleop: Binding<GameScores.AllianceScores.StageScores.Location>,
        ) -> Binding<GameScores.AllianceScores.StageScores.Location> {
            switch scoringStage {
            case .auto:
                return auto
            case .teleop:
                return teleop
            }
        }

        var locationBindings:
            Binding<GameScores.AllianceScores.StageScores.Location>
        {
            switch selectedBlueTeam {
            case .one:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.team1Location,
                    $scores.blue.teleop.team1Location
                )
            case .two:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.team2Location,
                    $scores.blue.teleop.team2Location
                )
            }
        }

        return locationBindings
    }

    func redLocationBinding() -> Binding<
        GameScores.AllianceScores.StageScores.Location
    > {
        func scoringStageBindingsSelector(
            _ auto: Binding<GameScores.AllianceScores.StageScores.Location>,
            _ teleop: Binding<GameScores.AllianceScores.StageScores.Location>,
        ) -> Binding<GameScores.AllianceScores.StageScores.Location> {
            switch scoringStage {
            case .auto:
                return auto
            case .teleop:
                return teleop
            }
        }

        var locationBindings:
            Binding<GameScores.AllianceScores.StageScores.Location>
        {
            switch selectedRedTeam {
            case .one:
                return scoringStageBindingsSelector(
                    $scores.red.auto.team1Location,
                    $scores.red.teleop.team1Location
                )
            case .two:
                return scoringStageBindingsSelector(
                    $scores.red.auto.team2Location,
                    $scores.red.teleop.team2Location
                )
            }
        }

        return locationBindings
    }
}

enum ScoringElement {
    case netZone, lowBasket, highBasket, lowChamber, highChamber, location,
        fouls
}

enum TeamSelection {
    case one, two
}

struct SelectorItem: View {
    let icon: String
    let name: String
    let element: ScoringElement
    @Binding var scoringElement: ScoringElement

    var body: some View {
        let selected = scoringElement == element

        HStack {
            Image(systemName: icon)
                .font(.title2)

            Spacer()

            Text(name)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxHeight: .infinity)
        .background(
            Rectangle().fill((selected ? Color.primary : .clear).gradient)
                .colorInvert()
        )
        .background(Color.secondary.opacity(0.1))
        .background(Color.primary.opacity(0.9).colorInvert())
        .background(Color.secondary.opacity(0.5))
        .colorInvert(selected)
        .radius(12)
        .onTapGesture {
            Haptics.play(.light)
            scoringElement = element
        }
    }
}

struct WheelPicker: View {
    @Binding var value: Int

    var body: some View {
        Picker(selection: $value) {
            ForEach(0..<41) { i in
                Text("\(i)")
                    .tag(i)
            }
        } label: {
        }
        .pickerStyle(.wheel)
    }
}

struct ScoreButtons: View {
    @Binding var value: Int
    let width: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            Button {
                Haptics.play(.light)
                value += 1
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .frame(
                        maxWidth: width,
                        maxHeight: .infinity
                    )
                    .background(
                        LinearGradient(
                            colors: [
                                .firstBlue.opacity(0.05),
                                .secondary.opacity(0.05),
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .leading
                        )
                    )
                    .background(Color.secondary.opacity(0.1))
                    .radius(8)
            }
            .disabled(value >= 40)

            Button {
                Haptics.play(.light)
                value -= 1
            } label: {
                Image(systemName: "minus")
                    .font(.title2)
                    .frame(
                        maxWidth: width,
                        maxHeight: .infinity
                    )
                    .background(
                        LinearGradient(
                            colors: [
                                .firstBlue.opacity(0.05),
                                .secondary.opacity(0.05),
                            ],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                    .background(Color.secondary.opacity(0.1))
                    .radius(8)
            }
            .disabled(value <= 0)
        }
        .tint(.primary)
    }
}

struct LocationButtons: View {
    @Binding var binding: GameScores.AllianceScores.StageScores.Location
    let scoringStage: ScoringStage

    var body: some View { EmptyView() }

    var none: some View {
        let location = GameScores.AllianceScores.StageScores.Location.none
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description(scoringStage))
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Rectangle().fill(
                    (locationSelected
                        ? Color.primary
                        : .clear).gradient
                ).colorInvert()
            )
            .colorInvert(locationSelected)
            .background(Color.secondary.opacity(0.15))
            .radius(8)
        }
        .tint(.primary)
    }

    var oZone: some View {
        let location = GameScores.AllianceScores.StageScores.Location.oZone
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description(scoringStage))
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Rectangle().fill(
                    (locationSelected
                        ? Color.primary
                        : .clear).gradient
                ).colorInvert()
            )
            .colorInvert(locationSelected)
            .background(
                Color.secondary.opacity(0.15)
            )
            .radius(8)
        }
        .tint(.primary)
    }

    var aZone: some View {
        let location = GameScores.AllianceScores.StageScores.Location.aZone
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description(scoringStage))
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Rectangle().fill(
                    (locationSelected
                        ? Color.primary
                        : .clear).gradient
                ).colorInvert()
            )
            .colorInvert(locationSelected)
            .background(
                Color.secondary.opacity(0.15)
            )
            .radius(8)
        }
        .tint(.primary)
    }

    var l2: some View {
        let location = GameScores.AllianceScores.StageScores.Location.l2
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(
                    location.description(scoringStage)
                )
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Rectangle().fill(
                    (locationSelected
                        ? Color.primary
                        : .clear).gradient
                ).colorInvert()
            )
            .colorInvert(locationSelected)
            .background(
                Color.secondary.opacity(0.15)
            )
            .radius(8)
        }
        .tint(.primary)
    }

    var l3: some View {
        let location = GameScores.AllianceScores.StageScores.Location.l3
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description(scoringStage))
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Rectangle().fill(
                    (locationSelected
                        ? Color.primary
                        : .clear).gradient
                ).colorInvert()
            )
            .colorInvert(locationSelected)
            .background(
                Color.secondary.opacity(0.15)
            )
            .radius(8)
        }
        .tint(.primary)
    }
}

struct FoulButtons: View {
    let icon: String
    let color: Color
    let width: CGFloat
    @Binding var fouls: Int

    var body: some View {
        VStack(spacing: 8) {
            Button {
                Haptics.play(.light)
                fouls += 1
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .foregroundStyle(color)

                    Text(String(fouls))
                        .font(.title)
                        .contentTransition(.numericText())
                }
                .padding(8)
                .maxArea()
                .background(Color.secondary.opacity(0.15))
                .radius(8)
            }
            .tint(.primary)

            Button {
                Haptics.play(.light)
                fouls -= 1
            } label: {
                Image(systemName: "minus")
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.15))
                    .radius(8)
            }
            .tint(.primary)
            .disabled(fouls <= 0)
        }
        .frame(width: width)
    }
}

#Preview {
    GameScoreView()
}
