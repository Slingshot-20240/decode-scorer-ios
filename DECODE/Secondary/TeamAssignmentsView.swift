//
//  TeamAssignmentsView.swift
//  DECODE
//
//  Created by Jining Liu on 9/7/25.
//

import SwiftUI

struct TeamAssignmentsView: View {
    @Binding var assignFor: AssignTeamFor?

    @Binding var redTeam1: String?
    @Binding var redTeam2: String?
    @Binding var blueTeam1: String?
    @Binding var blueTeam2: String?

    @State private var search: String

    let teams: [StoredTeam]

    init(
        assignFor: Binding<AssignTeamFor?>,
        redTeam1: Binding<String?>,
        redTeam2: Binding<String?>,
        blueTeam1: Binding<String?>,
        blueTeam2: Binding<String?>
    ) {
        _assignFor = assignFor
        _redTeam1 = redTeam1
        _redTeam2 = redTeam2
        _blueTeam1 = blueTeam1
        _blueTeam2 = blueTeam2
        self.search = ""
        self.teams = try! JSONDecoder().decode(
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
                            redTeam1
                        case .red2:
                            redTeam2
                        case .blue1:
                            blueTeam1
                        case .blue2:
                            blueTeam2
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
                                        redTeam1
                                    case .red2:
                                        redTeam2
                                    case .blue1:
                                        blueTeam1
                                    case .blue2:
                                        blueTeam2
                                    }
                                }

                                Text(selected ?? team.rawValue)
                                    .tag(team)
                            }
                        } label: {
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        ForEach(
                            teams.filter {
                                ($0.number + " " + $0.name).contains(search)
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
            }
        }
    }

    func assignTeam(_ team: String?) {
        if let assignFor {
            switch assignFor {
            case .red1:
                redTeam1 = team
            case .red2:
                redTeam2 = team
            case .blue1:
                blueTeam1 = team
            case .blue2:
                blueTeam2 = team
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
    @Previewable @State var redTeam1: String? = nil
    @Previewable @State var redTeam2: String? = nil
    @Previewable @State var blueTeam1: String? = nil
    @Previewable @State var blueTeam2: String? = nil

    TeamAssignmentsView(
        assignFor: $assignFor,
        redTeam1: $redTeam1,
        redTeam2: $redTeam2,
        blueTeam1: $blueTeam1,
        blueTeam2: $blueTeam2
    )
}
