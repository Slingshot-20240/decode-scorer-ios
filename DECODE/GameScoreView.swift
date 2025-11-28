//
//  GameScoreView.swift
//  DECODE
//
//  Created by Jining Liu on 7/19/25.
//

import SwiFTC
import SwiftUI

struct GameScoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var timer: GameTimerV1 = .shared
    @State private var scoringStage: GameScoringStageV1 = .auto
    @State private var scores: DecodeGameScores = .init()

    @State private var assignTeamFor: AssignTeamFor? = nil
    @AppStorage("scoringTeams") var scoringTeams: GameTeamsV1 = .init()

    @State private var timestamp: Date = .now

    @State private var batteryPercent: Float
    @State private var batteryIsCharging: Bool

    @State private var showDetails: Bool = false

    @State private var showSettings: Bool = false

    @State private var showSaveButtonWarning: Bool = false

    @StateObject private var orientation: OrientationManager = UIApplication
        .orientation

    @AppStorage("nfMode") private var nfMode: Bool = false
    @AppStorage("flipAlliances") private var flipAlliances: Bool = false
    @AppStorage("preserveTeamsAfterResetting") private
        var preserveTeamsAfterResetting: Bool = false
    @AppStorage("preserveTeamsAfterExiting") private
        var preserveTeamsAfterExiting: Bool = false

    @AppStorage("saveButtonWarningRead") private var saveButtonWarningRead:
        Bool = false

    init() {
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
                cornerRadius: (UIScreen.main.displayCornerRadius(min: 0) ?? 26)
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
        .sheet(isPresented: .constant(assignTeamFor != nil)) {
            assignTeamFor = nil
        } content: {
            TeamAssignmentsView(
                assignFor: $assignTeamFor,
                teams: $scoringTeams
            )
        }
        .sheet(isPresented: $showDetails) {
            details
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
        }
        .alert("Warning", isPresented: $showSaveButtonWarning) {
            Button("Save and Reset") {
                saveButtonWarningRead = true
                save()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                """
                Saving a game will also reset the scorer, even if the timer hasn't finished. Are you sure you want to continue?

                You will only be shown this warning once.
                """
            )
        }
        .onAppear {
            if !preserveTeamsAfterExiting {
                scoringTeams = .init()
            }
        }
        .onChange(of: timer.scoringStage) { _, stage in
            scoringStage = stage
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

    var topBar: some View {
        HStack(spacing: 16) {
            Menu("", systemImage: "line.3.horizontal") {
                ControlGroup {
                    Button("Save", systemImage: "square.and.arrow.down") {
                        if saveButtonWarningRead {
                            save()
                        } else {
                            showSaveButtonWarning = true
                        }
                    }
                    .disabled(scores.total <= 0)

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

                    Button(
                        "Reset",
                        systemImage: "arrow.2.circlepath",
                        role: .destructive
                    ) {
                        reset()
                    }
                }

                Divider()

                Button("Settings", systemImage: "gear") {
                    showSettings = true
                }

                Divider()

                Button(
                    "Exit",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    role: .destructive
                ) {
                    reset()
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

    @State private var scoringElement: ScoringElement = .classified

    var selector: some View {
        FractionalStack(
            .horizontal,
            divisions: 7,
            elements: 3,
            spacing: 8
        ) { fd in
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
                .foregroundStyle(scoringStage == .auto ? .secondary : .primary)
                .opacity(scoringStage == .auto ? 0.4 : 1)
                .disabled(scoringStage == .auto)
            }
            .frame(width: fd.divs(3))

            VStack(spacing: 8) {
                if let motif = scores.motif {
                    Image("AprilTags/\(motif.rawValue)")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()

                    Divider()

                    HStack(spacing: 8) {
                        Circle()
                            .fill(
                                motif == .gpp
                                    ? .artifactGreen : .artifactPurple
                            )
                        Circle()
                            .fill(
                                motif == .pgp
                                    ? .artifactGreen : .artifactPurple
                            )
                        Circle()
                            .fill(
                                motif == .ppg
                                    ? .artifactGreen : .artifactPurple
                            )
                    }
                } else {
                    Image(.DECODE)
                        .resizable()
                        .scaledToFit()
                }
            }
            .padding(12)
            .frame(width: fd.divs(1))
            .frame(maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .radius(12)
            .onTapGesture {
                Haptics.play(.light)

                withAnimation(.none) {
                    if let motif = scores.motif {
                        switch motif {
                        case .gpp:
                            scores.motif = .pgp
                        case .pgp:
                            scores.motif = .ppg
                        case .ppg:
                            scores.motif = nil
                        }
                    } else {
                        scores.motif = .gpp
                    }
                }
            }
            .contextMenu {
                Button("Randomize", systemImage: "dice") {
                    Haptics.play(.light)
                    scores.motif = .init(
                        rawValue: Int.random(in: 21..<24)
                    )
                }
            }

            VStack(spacing: 8) {
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
            .frame(width: fd.divs(3))
        }
    }

    @State private var selectedRedTeam: TeamSelection = .one
    @State private var selectedBlueTeam: TeamSelection = .one

    var scoreControls: some View {
        FractionalStack(.horizontal, divisions: 13, elements: 3, spacing: 8) {
            fd in
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    let team1Selected = selectedRedTeam == .one

                    Button {
                        Haptics.play(.light)
                        selectedRedTeam = .one
                    } label: {
                        Text(scoringTeams.red.one ?? "Team 1")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
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
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .disabled(scoringElement != .location)
                    .contextMenu {
                        Button(
                            "\(scoringTeams.red.one == nil ? "Assign" : "Change") Team",
                            systemImage: "person.3.fill"
                        ) {
                            Haptics.play(.light)
                            assignTeamFor = .red1
                        }
                    }

                    Button {
                        Haptics.play(.light)
                        selectedRedTeam = .two
                    } label: {
                        Text(scoringTeams.red.two ?? "Team 2")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
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
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .disabled(scoringElement != .location)
                    .contextMenu {
                        Button(
                            "\(scoringTeams.red.two == nil ? "Assign" : "Change") Team",
                            systemImage: "person.3.fill"
                        ) {
                            Haptics.play(.light)
                            assignTeamFor = .red2
                        }
                    }
                }
                .tint(.primary)
                .scaleEffect(x: flipAlliances ? -1 : 1)

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
                                    binding: redAutoLocationBinding(),
                                    scoringStage: scoringStage
                                )

                                locationButtons.none
                                    .scaleEffect(x: flipAlliances ? -1 : 1)
                                    .frame(width: fd.divs(1))
                                    .useDeviceCornerRadius(
                                        [.bottomLeading],
                                        min: 24,
                                        fallback: 8,
                                        subtract: 16
                                    )

                                locationButtons.left
                                    .scaleEffect(x: flipAlliances ? -1 : 1)
                                    .frame(width: fd.divs(2))
                            case .teleop:
                                let locationButtons = TeleopLocationButtons(
                                    binding: redTeleopLocationBinding(),
                                    scoringStage: scoringStage
                                )

                                locationButtons.none
                                    .scaleEffect(x: flipAlliances ? -1 : 1)
                                    .frame(width: fd.divs(1))
                                    .useDeviceCornerRadius(
                                        [.bottomLeading],
                                        min: 24,
                                        fallback: 8,
                                        subtract: 16
                                    )

                                HStack(spacing: 8) {
                                    VStack(spacing: 8) {
                                        locationButtons.partial
                                        locationButtons.full
                                    }
                                }
                                .scaleEffect(x: flipAlliances ? -1 : 1)
                                .frame(width: fd.divs(2))
                            }
                        }
                        .padding(8)
                    case .fouls:
                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark.3",
                            color: .red,
                            width: fd.divs(1),
                            fouls: $scores.blue
                                .majorFoulsFromOtherAllianceAwarded
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding([.vertical, .leading], 8)

                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark",
                            color: .yellow,
                            width: fd.divs(1),
                            fouls: $scores.blue
                                .minorFoulsFromOtherAllianceAwarded
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding([.vertical, .trailing], 8)

                        Spacer()
                    default:
                        WheelPicker(
                            value: scoringElementBindings().red,
                            max: scoringElement == .motifs ? 9 : 99
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding(.leading, 8)

                        ScoreButtons(
                            value: scoringElementBindings().red,
                            width: fd.divs(1)
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding([.vertical, .trailing], 8)
                    }
                }
                .maxArea()
                .background(.ultraThinMaterial)
                .background(
                    LinearGradient(
                        colors: [.firstRed, .clear, .clear],
                        startPoint: .bottomTrailing,
                        endPoint: .leading
                    ).opacity(0.2)
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
                                .maxArea()
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
                            save()
                        } label: {
                            Label(
                                "Save",
                                systemImage: "square.and.arrow.down.fill"
                            )
                            .font(.title2)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.6)
                            .padding(8)
                            .maxArea()
                            .background(
                                Rectangle().fill(Color.primary.gradient)
                                    .colorInvert().scaleEffect(y: -1)
                            )
                            .colorInvert()
                            .radius(8)
                        }
                        .disabled(scores.total <= 0)
                        .opacity(scores.total > 0 ? 1 : 0.4)
                        .brightness(scores.total > 0 ? 0 : -0.2)

                        Button {
                            Haptics.play(.light)
                            showDetails = true
                        } label: {
                            Label("Details", systemImage: "list.dash")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.6)
                                .padding(8)
                                .maxArea()
                                .background(
                                    Rectangle().fill(Color.primary.gradient)
                                        .colorInvert().scaleEffect(y: -1)
                                )
                                .colorInvert()
                                .radius(8)
                        }
                        .disabled(scores.total <= 0)
                        .opacity(scores.total > 0 ? 1 : 0.4)
                        .brightness(scores.total > 0 ? 0 : -0.2)
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
                .scaleEffect(x: flipAlliances ? -1 : 1)
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
                .contextMenu {
                    if ![GameTimerV1.Stage.standby, .finished].contains(
                        timer.timerStage
                    ) {
                        Button(
                            "Skip to Finished",
                            systemImage: "arrow.turn.up.right"
                        ) {
                            Haptics.play(.light)

                            timer.reset()
                            timer.timerStage = .finished
                        }
                    }
                }

                HStack(spacing: 8) {
                    Text("000")
                        .font(.system(size: 60, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(String(scores.red.total(excludeFouls: nfMode)))
                                .font(.system(size: 60, weight: .bold))
                                .minimumScaleFactor(0.6)
                                .contentTransition(.numericText())
                                .foregroundStyle(.white)
                        }
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .maxArea()
                        .background(.firstRed.gradient)
                        .radius(16)

                    Text("000")
                        .font(.system(size: 60, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(
                                String(scores.blue.total(excludeFouls: nfMode))
                            )
                            .font(.system(size: 60, weight: .bold))
                            .minimumScaleFactor(0.6)
                            .contentTransition(.numericText())
                            .foregroundStyle(.white)
                        }
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .maxArea()
                        .background(.firstBlue.gradient)
                        .radius(16)
                }
                .frame(height: fd.divs(6))
            }
            .frame(width: fd.divs(5))

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    let team1Selected = selectedBlueTeam == .one

                    Button {
                        Haptics.play(.light)
                        selectedBlueTeam = .one
                    } label: {
                        Text(scoringTeams.blue.one ?? "Team 1")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
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
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .disabled(scoringElement != .location)
                    .contextMenu {
                        Button(
                            "\(scoringTeams.blue.one == nil ? "Assign" : "Change") Team",
                            systemImage: "person.3.fill"
                        ) {
                            Haptics.play(.light)
                            assignTeamFor = .blue1
                        }
                    }

                    Button {
                        Haptics.play(.light)
                        selectedBlueTeam = .two
                    } label: {
                        Text(scoringTeams.blue.two ?? "Team 2")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
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
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .disabled(scoringElement != .location)
                    .contextMenu {
                        Button(
                            "\(scoringTeams.blue.two == nil ? "Assign" : "Change") Team",
                            systemImage: "person.3.fill"
                        ) {
                            Haptics.play(.light)
                            assignTeamFor = .blue2
                        }
                    }
                }
                .tint(.primary)
                .scaleEffect(x: flipAlliances ? -1 : 1)

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
                                    binding: blueAutoLocationBinding(),
                                    scoringStage: scoringStage
                                )

                                locationButtons.left
                                    .scaleEffect(x: flipAlliances ? -1 : 1)
                                    .frame(width: fd.divs(2))

                                locationButtons.none
                                    .scaleEffect(x: flipAlliances ? -1 : 1)
                                    .frame(width: fd.divs(1))
                                    .useDeviceCornerRadius(
                                        [.bottomTrailing],
                                        min: 24,
                                        fallback: 8,
                                        subtract: 16
                                    )
                            case .teleop:
                                let locationButtons = TeleopLocationButtons(
                                    binding: blueTeleopLocationBinding(),
                                    scoringStage: scoringStage
                                )

                                HStack(spacing: 8) {
                                    VStack(spacing: 8) {
                                        locationButtons.partial
                                        locationButtons.full
                                    }
                                }
                                .scaleEffect(x: flipAlliances ? -1 : 1)
                                .frame(width: fd.divs(2))

                                locationButtons.none
                                    .scaleEffect(x: flipAlliances ? -1 : 1)
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
                            width: fd.divs(1),
                            fouls: $scores.red
                                .minorFoulsFromOtherAllianceAwarded
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding([.vertical, .leading], 8)

                        Spacer()

                        FoulButtons(
                            icon: "exclamationmark.3",
                            color: .red,
                            width: fd.divs(1),
                            fouls: $scores.red
                                .majorFoulsFromOtherAllianceAwarded
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding([.vertical, .trailing], 8)

                        Spacer()
                    default:
                        ScoreButtons(
                            value: scoringElementBindings().blue,
                            width: fd.divs(1)
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding([.vertical, .leading], 8)

                        WheelPicker(
                            value: scoringElementBindings().blue,
                            max: scoringElement == .motifs ? 9 : 99
                        )
                        .scaleEffect(x: flipAlliances ? -1 : 1)
                        .padding(.trailing, 8)
                    }
                }
                .maxArea()
                .background(.ultraThinMaterial)
                .background(
                    LinearGradient(
                        colors: [.firstBlue, .clear, .clear],
                        startPoint: .bottomLeading,
                        endPoint: .trailing
                    ).opacity(0.25)
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
        .scaleEffect(x: flipAlliances ? -1 : 1)
        .animation(.smooth, value: scores.red.total(excludeFouls: nfMode))
        .animation(.smooth, value: scores.blue.total(excludeFouls: nfMode))
    }

    var details: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        Text(
                            timestamp.formatted(
                                date: .complete,
                                time: .complete
                            )
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                        var label: GameLabel {
                            let red1 = scoringTeams.red.one
                            let red2 = scoringTeams.red.two

                            let redLabel: String
                            if let r1 = red1, let r2 = red2 {
                                redLabel = "\(r1) & \(r2)"
                            } else if let r1 = red1 {
                                redLabel = "\(r1) & Team"
                            } else if let r2 = red2 {
                                redLabel = "Team & \(r2)"
                            } else {
                                redLabel = "Red Alliance"
                            }

                            let blue1 = scoringTeams.blue.one
                            let blue2 = scoringTeams.blue.two

                            let blueLabel: String
                            if let b1 = blue1, let b2 = blue2 {
                                blueLabel = "\(b1) & \(b2)"
                            } else if let b1 = blue1 {
                                blueLabel = "\(b1) & Team"
                            } else if let b2 = blue2 {
                                blueLabel = "Team & \(b2)"
                            } else {
                                blueLabel = "Blue Alliance"
                            }

                            if red1 == nil && red2 == nil && blue1 == nil
                                && blue2 == nil
                            {
                                return .init()
                            }

                            return .init(
                                red: redLabel,
                                middle: " v.s. ",
                                blue: blueLabel
                            )
                        }

                        if label.middle != "Game" {
                            let redWon =
                                scores.red.total(excludeFouls: nfMode)
                                >= scores.blue.total(excludeFouls: nfMode)
                            let blueWon =
                                scores.blue.total(excludeFouls: nfMode)
                                >= scores.red.total(excludeFouls: nfMode)

                            HStack(spacing: 8) {
                                Text(label.red)
                                    .foregroundStyle(
                                        redWon ? .firstRed : .primary
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .trailing
                                    )

                                Text(label.middle)
                                    .fontWeight(.regular)

                                Text(label.blue)
                                    .foregroundStyle(
                                        blueWon ? .firstBlue : .primary
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                            }
                            .font(.title2)
                            .fontWeight(.semibold)
                        }

                        ScoreDetailsView(scores: scores)
                    }
                    .padding(proxy.safeAreaInsets.bottom == 0 ? 16 : 0)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .navigationTitle("Details")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        DismissButton {
                            showDetails = false
                        }
                    }
                }
            }
        }
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
            case .classified:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.classfied,
                    $scores.blue.teleop.classfied,
                    $scores.red.auto.classfied,
                    $scores.red.teleop.classfied
                )
            case .overflown:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.overflown,
                    $scores.blue.teleop.overflown,
                    $scores.red.auto.overflown,
                    $scores.red.teleop.overflown
                )
            case .depot:
                return scoringStageBindingsSelector(
                    .constant(0),
                    $scores.blue.teleop.depot,
                    .constant(0),
                    $scores.red.teleop.depot
                )
            case .motifs:
                return scoringStageBindingsSelector(
                    $scores.blue.auto.matchingMotifs,
                    $scores.blue.teleop.matchingMotifs,
                    $scores.red.auto.matchingMotifs,
                    $scores.red.teleop.matchingMotifs
                )
            default:
                return (.constant(0), .constant(0))
            }
        }

        return scoringElementBindings
    }

    func blueAutoLocationBinding() -> Binding<
        DecodeGameScores.AllianceScores.AutoScores.Location
    > {
        switch selectedBlueTeam {
        case .one:
            return $scores.blue.auto.team1Location
        case .two:
            return $scores.blue.auto.team2Location
        }
    }

    func redAutoLocationBinding() -> Binding<
        DecodeGameScores.AllianceScores.AutoScores.Location
    > {
        switch selectedRedTeam {
        case .one:
            return $scores.red.auto.team1Location
        case .two:
            return $scores.red.auto.team2Location
        }
    }

    func blueTeleopLocationBinding() -> Binding<
        DecodeGameScores.AllianceScores.TeleopScores.Location
    > {
        switch selectedBlueTeam {
        case .one:
            return $scores.blue.teleop.team1Location
        case .two:
            return $scores.blue.teleop.team2Location
        }
    }

    func redTeleopLocationBinding() -> Binding<
        DecodeGameScores.AllianceScores.TeleopScores.Location
    > {
        switch selectedRedTeam {
        case .one:
            return $scores.red.teleop.team1Location
        case .two:
            return $scores.red.teleop.team2Location
        }
    }

    func save() {
        var teams = GameTeamsV1()
        teams.red.one = scoringTeams.red.one
        teams.red.two = scoringTeams.red.two
        teams.blue.one = scoringTeams.blue.one
        teams.blue.two = scoringTeams.blue.two

        modelContext.insert(
            DecodeGameModel(
                scores: scores,
                teams: teams,
                timestamp: timestamp
            )
        )

        do {
            try modelContext.save()
        } catch {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1
            ) {
                try? modelContext.save()
            }
        }

        Haptics.notify(.success)

        reset()
    }

    func reset() {
        Analytics.shared.trackCompletion(scores, from: .game)

        timer.reset()
        scores = .init()
        scoringStage = .auto
        scoringElement = .classified
        timestamp = .now

        if !preserveTeamsAfterResetting {
            scoringTeams = .init()
        }
    }
}

enum ScoringElement {
    case classified, overflown, depot, motifs, location, fouls
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
                .rotationEffect(.degrees(icon == "righttriangle" ? 180 : 0))

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
        .background(.ultraThinMaterial)
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
    let max: Int

    init(value: Binding<Int>, max: Int = 99) {
        _value = value
        self.max = max
    }

    var body: some View {
        Picker(selection: $value) {
            ForEach(0..<(max + 1), id: \.self) { i in
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
    let max: Int

    init(value: Binding<Int>, width: CGFloat, max: Int = 99) {
        _value = value
        self.width = width
        self.max = max
    }

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
            .disabled(value >= max)

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

struct AutoLocationButtons: View {
    @Binding var binding: DecodeGameScores.AllianceScores.AutoScores.Location
    let scoringStage: GameScoringStageV1

    var body: some View { EmptyView() }

    var none: some View {
        let location = DecodeGameScores.AllianceScores.AutoScores.Location.none
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description)
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .maxArea()
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

    var left: some View {
        let location = DecodeGameScores.AllianceScores.AutoScores.Location.left
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description)
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .maxArea()
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

struct TeleopLocationButtons: View {
    @Binding var binding: DecodeGameScores.AllianceScores.TeleopScores.Location
    let scoringStage: GameScoringStageV1

    var body: some View { EmptyView() }

    var none: some View {
        let location = DecodeGameScores.AllianceScores.TeleopScores.Location
            .none
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description)
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .maxArea()
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

    var partial: some View {
        let location = DecodeGameScores.AllianceScores.TeleopScores.Location
            .partial
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description)
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .maxArea()
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

    var full: some View {
        let location = DecodeGameScores.AllianceScores.TeleopScores.Location
            .full
        let locationSelected = binding == location

        return Button {
            Haptics.play(.light)
            binding = location
        } label: {
            VStack(spacing: 4) {
                Image(systemName: location.icon)
                Text(location.description)
            }
            .font(.caption)
            .minimumScaleFactor(0.6)
            .padding(4)
            .maxArea()
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
                .minimumScaleFactor(0.8)
                .padding(8)
                .maxArea()
                .background {
                    Rectangle()
                        .fill(color.gradient)
                        .opacity(0.2)
                }
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
                    .background(.ultraThinMaterial)
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
