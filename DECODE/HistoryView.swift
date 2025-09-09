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

    @State private var assignTeamForGame: DecodeGameModel? = nil
    @State private var assignTeamFor: AssignTeamFor? = nil
    @State private var redTeam1: String? = nil
    @State private var redTeam2: String? = nil
    @State private var blueTeam1: String? = nil
    @State private var blueTeam2: String? = nil

    var body: some View {
        NavigationStack {
            List {
                if games.isEmpty {
                    Text("No History")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                ForEach(games) { game in
                    NavigationLink(value: game) {
                        HStack {
                            let redWon =
                                game.scores.red.total >= game.scores.blue.total
                            let blueWon =
                                game.scores.blue.total >= game.scores.red.total

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

                            Text("\(game.scores.red.total)")
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

                            Text("\(game.scores.blue.total)")
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
            }
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
                                    game.scores.red.total
                                    >= game.scores.blue.total
                                let blueWon =
                                    game.scores.blue.total
                                    >= game.scores.red.total

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
                                    redTeam1 = game.teams.red.one
                                    redTeam2 = game.teams.red.two
                                    blueTeam1 = game.teams.blue.one
                                    blueTeam2 = game.teams.blue.two
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
            assignTeamForGame?.teams.red.one = redTeam1
            assignTeamForGame?.teams.red.two = redTeam2
            assignTeamForGame?.teams.blue.one = blueTeam1
            assignTeamForGame?.teams.blue.two = blueTeam2

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
                redTeam1: $redTeam1,
                redTeam2: $redTeam2,
                blueTeam1: $blueTeam1,
                blueTeam2: $blueTeam2
            )
        }
    }
}

#Preview {
    HistoryView()
}
