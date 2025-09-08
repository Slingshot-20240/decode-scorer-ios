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
                .background(Color.secondary.opacity(0.1))
                .background(Color.primary.opacity(0.9).colorInvert())
                .background(Color.secondary.opacity(0.5))
                .clipShape(Capsule())
            }
        }
    }

    @State var autoLabelSize: CGSize = .init()

    var auto: some View {
        HStack(spacing: 8) {
            Text("Auto")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .colorInvert()
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
                .padding(8)
                .frame(maxHeight: .infinity)
                .background(Color.primary)
                .colorInvert()
                .radius(8)
                .radius(16, corners: [.topLeading, .bottomLeading])

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
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .background(Color.primary.opacity(0.9).colorInvert())
        .background(Color.secondary.opacity(0.5))
        .radius(24)
    }

    @State var teleopLabelSize: CGSize = .init()

    var teleop: some View {
        HStack(spacing: 8) {
            Text("Teleop")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .colorInvert()
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
                .padding(8)
                .frame(maxHeight: .infinity)
                .background(Color.primary)
                .colorInvert()
                .radius(8)
                .radius(16, corners: [.topLeading, .bottomLeading])

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
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .background(Color.primary.opacity(0.9).colorInvert())
        .background(Color.secondary.opacity(0.5))
        .radius(24)
    }
}

struct NumericCard: View {
    let icon: String
    let name: String
    let red: Int
    let blue: Int

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.headline)
                    .rotationEffect(.degrees(icon == "righttriangle" ? 180 : 0))

                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.primary)
            .colorInvert()
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary)
            .colorInvert()
            .radius(12)
            .shadow(color: .secondary.opacity(0.2), radius: 8)
            .zIndex(1)

            HStack(spacing: 16) {
                Text("\(red)")
                    .frame(maxWidth: .infinity)

                Text("\(blue)")
                    .frame(maxWidth: .infinity)
            }
            .font(.title2)
            .fontWeight(.semibold)
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
                        .fill(.white)
                        .frame(width: 0)
                    Rectangle()
                        .fill(
                            (blue >= red
                                ? Color.firstBlue : .secondary.opacity(0.8))
                                .gradient
                        )
                }
                .padding(.top, -12)
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
            HStack(spacing: 16) {
                Label(red1Label, systemImage: red1Icon)
                    .frame(maxWidth: .infinity)

                Label(red2Label, systemImage: red2Icon)
                    .frame(maxWidth: .infinity)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            (red1Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstRed)
                                .gradient
                        )
                        .brightness(-0.1)
                    Rectangle()
                        .fill(.white)
                        .frame(width: 0)
                    Rectangle()
                        .fill(
                            (red2Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstRed)
                                .gradient
                        )
                        .padding(
                            .trailing,
                            -12
                        )
                }
            }
            .zIndex(0)

            HStack(spacing: 4) {
                Image(systemName: "location.fill.viewfinder")
                    .font(.headline)

                Text("Location")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.primary)
            .colorInvert()
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)
            .background(Color.primary)
            .colorInvert()
            .radius(12)
            .shadow(radius: 4)
            .zIndex(1)

            HStack(spacing: 16) {
                Label(blue1Label, systemImage: blue1Icon)
                    .frame(maxWidth: .infinity)
                Label(blue2Label, systemImage: blue2Icon)
                    .frame(maxWidth: .infinity)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            (blue1Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstBlue)
                                .gradient
                        )
                        .padding(
                            .leading,
                            -12
                        )
                    Rectangle()
                        .fill(.white)
                        .frame(width: 0)
                    Rectangle()
                        .fill(
                            (blue2Label == "None"
                                ? Color.secondary.opacity(0.8) : .firstBlue)
                                .gradient
                        )
                        .brightness(-0.1)
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
        return temp
    }

    ScrollView {
        ScoreDetailsView(scores: scores)
            .safeAreaPadding()
    }
}
