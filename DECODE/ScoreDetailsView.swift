//
//  ScoreDetailsView.swift
//  DECODE
//
//  Created by Jining Liu on 9/7/25.
//

import SwiFTC
import SwiftUI

struct ScoreDetailsView: View {
    let scores: DecodeGameScores
    let largeSeparator: Bool

    init(scores: DecodeGameScores, largeSeparator: Bool = false) {
        self.scores = scores
        self.largeSeparator = largeSeparator
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                let redWon = scores.red.total >= scores.blue.total
                Text("\(scores.red.total)")
                    .font(.largeTitle)
                    .fontWeight(redWon ? .bold : .semibold)
                    .foregroundStyle(redWon ? .white : .firstRed)
                    .padding(.horizontal, redWon ? 12 : 0)
                    .padding(.vertical, 4)
                    .background(
                        redWon ? Color.firstRed.gradient : Color.clear.gradient
                    )
                    .radius(16)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if largeSeparator {
                    Text(" v.s. ")
                        .font(.title2)
                        .fontWeight(.regular)
                        .opacity(0)
                } else {
                    Divider()
                }

                let blueWon = scores.blue.total >= scores.red.total
                Text("\(scores.blue.total)")
                    .font(.largeTitle)
                    .fontWeight(blueWon ? .bold : .semibold)
                    .foregroundStyle(blueWon ? .white : .firstBlue)
                    .padding(.horizontal, blueWon ? 12 : 0)
                    .padding(.vertical, 4)
                    .background(
                        blueWon
                            ? Color.firstBlue.gradient : Color.clear.gradient
                    )
                    .radius(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fontWeight(.semibold)

            auto

            teleop

            HStack(spacing: 8) {
                Text("\(scores.red.foulPointsFromOtherAllianceAwarded)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.firstRed)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("Fouls")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(scores.blue.foulPointsFromOtherAllianceAwarded)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.firstBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let motif = scores.motif {
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
                .frame(height: 16)
                .padding(8)
                .glassBackground()
            }
        }
    }

    @State var autoLabelSize: CGSize = .init()
    @State var autoRedScoreLabelSize: CGSize = .init()
    @State var autoBlueScoreLabelSize: CGSize = .init()

    var auto: some View {
        HStack(spacing: 8) {
            Text("Auto")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(8)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                autoLabelSize = .init(
                                    width: proxy.size.height,
                                    height: proxy.size.width
                                )
                            }
                    }
                }
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .frame(
                    width: autoLabelSize.width,
                    height: autoLabelSize.height
                )
                .frame(maxHeight: .infinity)
                .glassBackground(
                    shape: UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 8
                    )
                )

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    NumericCard(
                        icon: "tray.full",
                        name: "Classified",
                        red: scores.red.auto.classfied,
                        blue: scores.blue.auto.classfied
                    )

                    NumericCard(
                        icon: "arrowshape.bounce.forward",
                        name: "Overflown",
                        red: scores.red.auto.overflown,
                        blue: scores.blue.auto.overflown
                    )

                    NumericCard(
                        icon: "swatchpalette",
                        name: "Motifs",
                        red: scores.red.auto.matchingMotifs,
                        blue: scores.blue.auto.matchingMotifs
                    )
                }
                .fixedSize(horizontal: false, vertical: true)

                LocationCard(
                    red1Label: scores.red.auto.team1Location.description,
                    red1Icon: scores.red.auto.team1Location.icon,
                    red2Label: scores.red.auto.team2Location.description,
                    red2Icon: scores.red.auto.team2Location.icon,
                    blue1Label: scores.blue.auto.team1Location.description,
                    blue1Icon: scores.blue.auto.team1Location.icon,
                    blue2Label: scores.blue.auto.team2Location.description,
                    blue2Icon: scores.blue.auto.team2Location.icon
                )
            }

            let redWon = scores.red.auto.total >= scores.blue.auto.total
            let blueWon = scores.blue.auto.total >= scores.red.auto.total

            let redScoreLabel = Text("\(scores.red.auto.total)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(redWon ? .white : .firstRed)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    redWon ? Color.firstRed.gradient : Color.clear.gradient
                )
                .radius(4)
                .radius(12, corners: [.topLeading])
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                autoRedScoreLabelSize = .init(
                                    width: proxy.size.height,
                                    height: proxy.size.width
                                )
                            }
                    }
                }
                .rotationEffect(.degrees(90))
                .fixedSize()
                .frame(
                    width: autoRedScoreLabelSize.width,
                    height: autoRedScoreLabelSize.height
                )

            let blueScoreLabel = Text("\(scores.blue.auto.total)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(blueWon ? .white : .firstBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    blueWon
                        ? Color.firstBlue.gradient : Color.clear.gradient
                )
                .radius(4)
                .radius(12, corners: [.topTrailing])
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                autoBlueScoreLabelSize = .init(
                                    width: proxy.size.height,
                                    height: proxy.size.width
                                )
                            }
                    }
                }
                .rotationEffect(.degrees(90))
                .fixedSize()
                .frame(
                    width: autoBlueScoreLabelSize.width,
                    height: autoBlueScoreLabelSize.height
                )

            VStack {
                redScoreLabel
                Spacer()
                blueScoreLabel
            }
            .padding(4)
            .glassBackground(
                shape: UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 16
                )
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(8)
        .background(.ultraThinMaterial)
        .radius(24)
    }

    @State var teleopLabelSize: CGSize = .init()
    @State var teleopRedScoreLabelSize: CGSize = .init()
    @State var teleopBlueScoreLabelSize: CGSize = .init()

    var teleop: some View {
        HStack(spacing: 8) {
            Text("Teleop")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(8)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                teleopLabelSize = .init(
                                    width: proxy.size.height,
                                    height: proxy.size.width
                                )
                            }
                    }
                }
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .frame(
                    width: teleopLabelSize.width,
                    height: teleopLabelSize.height
                )
                .frame(maxHeight: .infinity)
                .glassBackground(
                    shape: UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 8
                    )
                )

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    NumericCard(
                        icon: "tray.full",
                        name: "Classified",
                        red: scores.red.teleop.classfied,
                        blue: scores.blue.teleop.classfied
                    )

                    NumericCard(
                        icon: "arrowshape.bounce.forward",
                        name: "Overflown",
                        red: scores.red.teleop.overflown,
                        blue: scores.blue.teleop.overflown
                    )

                    NumericCard(
                        icon: "righttriangle",
                        name: "Depot",
                        red: scores.red.teleop.depot,
                        blue: scores.blue.teleop.depot
                    )

                    NumericCard(
                        icon: "swatchpalette",
                        name: "Motifs",
                        red: scores.red.teleop.matchingMotifs,
                        blue: scores.blue.teleop.matchingMotifs
                    )
                }
                .fixedSize(horizontal: false, vertical: true)

                LocationCard(
                    red1Label: scores.red.teleop.team1Location.description,
                    red1Icon: scores.red.teleop.team1Location.icon,
                    red2Label: scores.red.teleop.team2Location.description,
                    red2Icon: scores.red.teleop.team2Location.icon,
                    blue1Label: scores.blue.teleop.team1Location.description,
                    blue1Icon: scores.blue.teleop.team1Location.icon,
                    blue2Label: scores.blue.teleop.team2Location.description,
                    blue2Icon: scores.blue.teleop.team2Location.icon
                )
            }

            let redWon = scores.red.teleop.total >= scores.blue.teleop.total
            let blueWon = scores.blue.teleop.total >= scores.red.teleop.total

            let redScoreLabel = Text("\(scores.red.teleop.total)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(redWon ? .white : .firstRed)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    redWon ? Color.firstRed.gradient : Color.clear.gradient
                )
                .radius(4)
                .radius(12, corners: [.topLeading])
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                teleopRedScoreLabelSize = .init(
                                    width: proxy.size.height,
                                    height: proxy.size.width
                                )
                            }
                    }
                }
                .rotationEffect(.degrees(90))
                .fixedSize()
                .frame(
                    width: teleopRedScoreLabelSize.width,
                    height: teleopRedScoreLabelSize.height
                )

            let blueScoreLabel = Text("\(scores.blue.teleop.total)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(blueWon ? .white : .firstBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    blueWon
                        ? Color.firstBlue.gradient : Color.clear.gradient
                )
                .radius(4)
                .radius(12, corners: [.topTrailing])
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                teleopBlueScoreLabelSize = .init(
                                    width: proxy.size.height,
                                    height: proxy.size.width
                                )
                            }
                    }
                }
                .rotationEffect(.degrees(90))
                .fixedSize()
                .frame(
                    width: teleopBlueScoreLabelSize.width,
                    height: teleopBlueScoreLabelSize.height
                )

            VStack {
                redScoreLabel
                Spacer()
                blueScoreLabel
            }
            .padding(4)
            .glassBackground(
                shape: UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 16
                )
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(8)
        .background(.ultraThinMaterial)
        .radius(24)
    }
}

struct NumericCard: View {
    let icon: String
    let name: String
    let red: Int
    let blue: Int

    var body: some View {
        VStack(spacing: -8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .rotationEffect(.degrees(icon == "righttriangle" ? 180 : 0))

                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .zIndex(1)
            .glassBackground()

            HStack(spacing: 16) {
                Text("\(red)")
                    .frame(maxWidth: .infinity)

                Text("\(blue)")
                    .frame(maxWidth: .infinity)
            }
            .font(.title2)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.8)
            .foregroundStyle(.white)
            .padding(8)
            .background {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            (red >= blue
                                ? Color.firstRed : .secondary.opacity(0.8))
                                .gradient
                        )
                    Rectangle()
                        .fill(
                            (blue >= red
                                ? Color.firstBlue : .secondary.opacity(0.8))
                                .gradient
                        )
                }
                .radius(16)
            }
            .zIndex(0)
        }
        .radius(16)
    }
}

struct LocationCard: View {
    let red1Label: String
    let red1Icon: String
    let red2Label: String
    let red2Icon: String
    let blue1Label: String
    let blue1Icon: String
    let blue2Label: String
    let blue2Icon: String

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 24) {
                Label(red1Label, systemImage: red1Icon)
                    .frame(maxWidth: .infinity)
                    .offset(x: 8)

                Label(red2Label, systemImage: red2Icon)
                    .frame(maxWidth: .infinity)
                    .offset(x: 24)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            .foregroundStyle(.white)
            .padding(12)
            .background {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            (red1Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstRed)
                                .gradient
                        )
                        .brightness(-0.1)
                        .padding(.trailing, -16)
                    Rectangle()
                        .fill(
                            (red2Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstRed)
                                .gradient
                        )
                        .padding(.leading, 16)
                }
            }
            .zIndex(0)

            HStack(spacing: 4) {
                Image(systemName: "location.fill.viewfinder")
                    .font(.subheadline)

                Text("Location")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .zIndex(1)
            .glassBackground()
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 32)
            .background {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            (red2Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstRed)
                                .gradient
                        )
                    Rectangle()
                        .fill(
                            (blue1Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstBlue)
                                .gradient
                        )
                }
                .overlay(
                    LinearGradient(
                        colors: [.clear, .gray, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }

            HStack(spacing: 24) {
                Label(blue1Label, systemImage: blue1Icon)
                    .frame(maxWidth: .infinity)
                    .offset(x: -24)
                Label(blue2Label, systemImage: blue2Icon)
                    .frame(maxWidth: .infinity)
                    .offset(x: -8)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            .foregroundStyle(.white)
            .padding(12)
            .background {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            (blue1Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstBlue)
                                .gradient
                        )
                        .padding(.trailing, 16)
                    Rectangle()
                        .fill(
                            (blue2Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstBlue)
                                .gradient
                        )
                        .brightness(-0.1)
                        .padding(.leading, -16)
                }
            }
            .zIndex(0)
        }
        .radius(16)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    var scores: DecodeGameScores {
        var temp = DecodeGameScores()
        temp.motif = .gpp
        temp.blue.auto.classfied = 100
        temp.red.auto.overflown = 100
        temp.red.majorFoulsFromOtherAllianceAwarded = 1
        temp.red.auto.team1Location = .left
        temp.red.teleop.team1Location = .full
        temp.blue.teleop.team1Location = .partial
        return temp
    }

    ScrollView {
        ScoreDetailsView(scores: scores)
            .safeAreaPadding()
    }
}
