//
//  TeamAssignmentsView.swift
//  DECODE
//
//  Created by Jining Liu on 9/7/25.
//

import SwiFTC
import SwiftUI

struct TeamAssignmentsView: View {
    @Binding var assignFor: AssignTeamFor?
    @Binding var teams: GameTeamsV1

    @State private var search: String

    let teamsStore: [StoredTeam]

    init(
        assignFor: Binding<AssignTeamFor?>,
        teams: Binding<GameTeamsV1>,
    ) {
        _assignFor = assignFor
        _teams = teams
        self.search = ""
        self.teamsStore = try! JSONDecoder().decode(
            [StoredTeam].self,
            from: Data(
                contentsOf: Bundle.main.url(
                    forResource: "teams",
                    withExtension: "json"
                )!
            )
        )
    }

    var body: some View {
        NavigationStack {
            List {
                if let team = assignFor {
                    var selected: String? {
                        switch team {
                        case .red1:
                            teams.red.one
                        case .red2:
                            teams.red.two
                        case .blue1:
                            teams.blue.one
                        case .blue2:
                            teams.blue.two
                        }
                    }

                    Section {
                        Button {
                            assignTeam(nil)
                        } label: {
                            HStack {
                                Text("Unassigned")
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)

                                Spacer()

                                if selected == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } header: {
                        Picker(selection: $assignFor) {
                            ForEach(AssignTeamFor.allCases, id: \.rawValue) {
                                team in
                                var selected: String? {
                                    switch team {
                                    case .red1:
                                        teams.red.one
                                    case .red2:
                                        teams.red.two
                                    case .blue1:
                                        teams.blue.one
                                    case .blue2:
                                        teams.blue.two
                                    }
                                }

                                Text(selected ?? team.rawValue)
                                    .tag(team)
                            }
                        } label: {
                        }
                        .pickerStyle(.segmented)
                    }
                    .headerProminence(.increased)

                    Section {
                        ForEach(
                            teamsStore.filter {
                                ($0.number + " " + $0.name).lowercased()
                                    .contains(search.lowercased())
                                    || search.isEmpty
                            },
                            id: \.number
                        ) { team in
                            Button {
                                assignTeam(team.number)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(team.number)
                                            .font(.subheadline)
                                        Text(team.name)
                                            .font(.headline)
                                    }
                                    .foregroundStyle(Color.primary)

                                    Spacer()

                                    if selected == team.number {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Search team number or name")
            .navigationTitle("Team Assignments")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        assignFor = nil
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu("", systemImage: "ellipsis") {
                        Button("Clear Teams", systemImage: "clear") {
                            teams = .init()
                        }
                    }
                    .labelStyle(.iconOnly)
                }
            }
        }
    }

    func assignTeam(_ team: String?) {
        if let assignFor {
            switch assignFor {
            case .red1:
                teams.red.one = team
            case .red2:
                teams.red.two = team
            case .blue1:
                teams.blue.one = team
            case .blue2:
                teams.blue.two = team
            }
        }
    }
}

enum AssignTeamFor: String, CaseIterable {
    case red1 = "Red Team 1"
    case red2 = "Red Team 2"
    case blue1 = "Blue Team 1"
    case blue2 = "Blue Team 2"
}

struct StoredTeam: Codable {
    let number: String
    let name: String
}

#Preview {
    @Previewable @State var assignFor: AssignTeamFor? = .red1
    @Previewable @State var teams: GameTeamsV1 = .init()

    TeamAssignmentsView(
        assignFor: $assignFor,
        teams: $teams
    )
}
