//
//  HistoryView.swift
//  DECODE
//
//  Created by Jining Liu on 9/7/25.
//

import SwiFTC
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \DecodeGameModel.timestamp, order: .reverse) private var games:
        [DecodeGameModel]

    @State private var gamesSectionExpanded: Bool = true

    @State private var search: String = ""

    @State private var assignTeamForGame: DecodeGameModel? = nil
    @State private var assignTeamFor: AssignTeamFor? = nil
    @State private var teams: GameTeamsV1 = .init()

    @AppStorage("nfMode") private var nfMode: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if search.isEmpty {
                    stats
                }

                Section(isExpanded: $gamesSectionExpanded) {
                    if games.isEmpty {
                        Text("No Saved Games")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    ForEach(
                        games.filter {
                            "\($0.label.red) \($0.label.middle) \($0.label.blue) \($0.timestamp.formatted()) \($0.scores.red.total(excludeFouls: nfMode)) \($0.scores.red.total(excludeFouls: nfMode)) \($0.scores.blue.total(excludeFouls: nfMode))"
                                .lowercased().contains(search.lowercased())
                                || search.isEmpty
                        }
                    ) { game in
                        NavigationLink(value: game) {
                            HStack {
                                let redWon =
                                    game.scores.red.total(excludeFouls: nfMode)
                                    >= game.scores.blue.total(
                                        excludeFouls: nfMode
                                    )
                                let blueWon =
                                    game.scores.blue.total(excludeFouls: nfMode)
                                    >= game.scores.red.total(
                                        excludeFouls: nfMode
                                    )

                                VStack(alignment: .leading) {
                                    AnyView(
                                        Text(game.label.red)
                                            .foregroundStyle(
                                                redWon ? .firstRed : .primary
                                            )
                                            + Text(game.label.middle)
                                            + Text(game.label.blue)
                                            .foregroundStyle(
                                                blueWon ? .firstBlue : .primary
                                            )
                                    )
                                    .font(.headline)

                                    Text(game.timestamp.formatted())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(
                                    "\(game.scores.red.total(excludeFouls: nfMode))"
                                )
                                .font(.title3)
                                .fontWeight(redWon ? .bold : .semibold)
                                .foregroundStyle(redWon ? .white : .firstRed)
                                .padding(.horizontal, redWon ? 8 : 0)
                                .padding(.vertical, 4)
                                .background(
                                    redWon
                                        ? Color.firstRed.gradient
                                        : Color.clear.gradient
                                )
                                .radius(12)

                                Text(
                                    "\(game.scores.blue.total(excludeFouls: nfMode))"
                                )
                                .font(.title3)
                                .fontWeight(blueWon ? .bold : .semibold)
                                .foregroundStyle(blueWon ? .white : .firstBlue)
                                .padding(.horizontal, blueWon ? 8 : 0)
                                .padding(.vertical, 4)
                                .background(
                                    blueWon
                                        ? Color.firstBlue.gradient
                                        : Color.clear.gradient
                                )
                                .radius(12)
                            }
                        }
                    }
                    .onDelete { offsets in
                        withAnimation {
                            for index in offsets {
                                modelContext.delete(games[index])
                            }
                        }
                    }
                } header: {
                    Label("Games", systemImage: "gamecontroller")
                }
            }
            .searchable(text: $search)
            .navigationDestination(for: DecodeGameModel.self) { game in
                GeometryReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            Text(
                                game.timestamp.formatted(
                                    date: .complete,
                                    time: .complete
                                )
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                            if game.label.middle != "Game" {
                                let redWon =
                                    game.scores.red.total(excludeFouls: nfMode)
                                    >= game.scores.blue.total(
                                        excludeFouls: nfMode
                                    )
                                let blueWon =
                                    game.scores.blue.total(excludeFouls: nfMode)
                                    >= game.scores.red.total(
                                        excludeFouls: nfMode
                                    )

                                HStack(spacing: 8) {
                                    Text(game.label.red)
                                        .foregroundStyle(
                                            redWon ? .firstRed : .primary
                                        )
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .trailing
                                        )

                                    Text(game.label.middle)
                                        .fontWeight(.regular)

                                    Text(game.label.blue)
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

                            ScoreDetailsView(
                                scores: game.scores,
                                largeSeparator: game.label.middle != "Game"
                            )
                        }
                        .padding(proxy.safeAreaInsets.bottom == 0 ? 16 : 0)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .navigationTitle("Details")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu("", systemImage: "ellipsis") {
                                Button(
                                    "Edit Teams",
                                    systemImage: "person.3.fill"
                                ) {
                                    assignTeamForGame = game
                                    teams = game.teams
                                    assignTeamFor = .red1
                                }
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                }
            }
            .navigationTitle("History & Analysis")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: .constant(assignTeamFor != nil)) {
            assignTeamFor = nil
            assignTeamForGame?.teams = teams

            do {
                try modelContext.save()
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    try? modelContext.save()
                }
            }
        } content: {
            TeamAssignmentsView(
                assignFor: $assignTeamFor,
                teams: $teams
            )
        }
    }

    var stats: some View {
        Section {
        } header: {
            HStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Sessions")
                            .font(.title3)
                        Text("\(Analytics.shared.totalSessionsTracked)")
                            .font(.largeTitle)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("\(games.count) Saved")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "gamecontroller")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Analytics.shared.gamesTracked)")
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "autostartstop")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(
                                "\(Analytics.shared.autoSessionsTracked)"
                            )
                            .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "steeringwheel")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(
                                "\(Analytics.shared.dpSessionsTracked)"
                            )
                            .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(
                                "\(Analytics.shared.epSessionsTracked)"
                            )
                            .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "plus.slash.minus")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(
                                "\(Analytics.shared.calcSessionsTracked)"
                            )
                            .fontWeight(.semibold)
                        }
                    }
                    .font(.caption)
                    .fixedSize()
                }
                .foregroundStyle(.white)
                .padding()
                .background(.decodeGold.gradient)
                .radius(24)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Artifacts")
                            .font(.title3)
                        Text(
                            "\(Analytics.shared.totalArtifactsTracked)"
                        )
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                        Spacer()

                        Text(
                            "\(Analytics.shared.pointsTracked) Points Tracked"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "tray.full")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(
                                "\(Analytics.shared.classifiedArtifactsTracked)"
                            )
                            .fontWeight(.semibold)
                        }

                        HStack {
                            Image(
                                systemName: "arrowshape.bounce.forward"
                            )
                            .foregroundStyle(.secondary)
                            Spacer()
                            Text(
                                "\(Analytics.shared.overflownArtifactsTracked)"
                            )
                            .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "righttriangle")
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(180))
                            Spacer()
                            Text(
                                "\(Analytics.shared.depotArtifactsTracked)"
                            )
                            .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "swatchpalette")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Analytics.shared.motifsTracked)")
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.caption)
                    .fixedSize()
                }
                .foregroundStyle(.white)
                .padding()
                .background(.decodeGreen.gradient)
                .radius(24)
            }
            .shadow(color: .secondary.opacity(0.2), radius: 16)
        }
    }
}

#Preview {
    HistoryView()
}
