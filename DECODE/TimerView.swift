//
//  TimerView.swift
//  DECODE
//
//  Created by Jining Liu on 7/23/25.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var timer: GameTimer = .shared
    @State private var startFrom: ScoringStage = .auto

    var body: some View {
        GeometryReader { proxy in
            VStack {
                if timer.paused {
                    Button("Resume", systemImage: "play.fill") {
                        withAnimation(.smooth) {
                            timer.resume()
                        }
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                } else if !timer.inProgress {
                    HStack {
                        Button("", systemImage: "speaker.slash.fill") {
                            withAnimation(.smooth) {
                                timer.start(
                                    from: startFrom.timerStartStage,
                                    mute: true
                                )
                            }
                        }
                        .labelStyle(.iconOnly)
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)

                        Button(
                            "Start **\(startFrom.rawValue)**",
                            systemImage: "play.fill"
                        ) {
                            withAnimation(.smooth) {
                                timer.start(from: startFrom.timerStartStage)
                            }
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                    }
                }

                Spacer()

                Text(
                    "\(timer.countdown / 60):\(timer.countdown % 60, specifier: "%02d")"
                )
                .font(.system(size: 512, weight: .semibold))
                .monospacedDigit()
                .minimumScaleFactor(0.2)
                .contentTransition(.numericText())
                .animation(.smooth, value: timer.countdown)

                Spacer()

                Menu("", systemImage: "line.3.horizontal") {
                    if !timer.inProgress && !timer.paused {
                        Menu(
                            "Start from",
                            systemImage:
                                "point.bottomleft.filled.forward.to.point.topright.scurvepath"
                        ) {
                            Picker(
                                selection: $startFrom
                            ) {
                                ForEach(ScoringStage.allCases, id: \.rawValue) {
                                    stage in
                                    Text(stage.rawValue)
                                        .tag(stage)
                                }
                            } label: {
                            }
                        }
                    } else {
                        ControlGroup {
                            Button(
                                timer.paused ? "Resume" : "Pause",
                                systemImage:
                                    "\(timer.paused ? "play" : "pause").fill"
                            ) {
                                withAnimation(.smooth) {
                                    if timer.paused {
                                        timer.resume()
                                    } else {
                                        timer.pause()
                                    }
                                }
                            }
                            .disabled(!timer.inProgress)

                            Button("Reset", systemImage: "arrow.2.circlepath") {
                                withAnimation(.smooth) {
                                    timer.reset()
                                }
                            }
                        }
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
                .menuOrder(.fixed)
                .labelStyle(.iconOnly)
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
            }
            .padding(
                .leading,
                max(
                    proxy.safeAreaInsets.trailing
                        - proxy.safeAreaInsets.leading,
                    max(8 - proxy.safeAreaInsets.leading, 0)
                )
            )
            .padding(
                .trailing,
                max(
                    proxy.safeAreaInsets.leading
                        - proxy.safeAreaInsets.trailing,
                    max(8 - proxy.safeAreaInsets.trailing, 0)
                )
            )
            .padding(
                .top,
                max(
                    proxy.safeAreaInsets.bottom
                        - proxy.safeAreaInsets.top,
                    max(8 - proxy.safeAreaInsets.top, 0)
                )
            )
            .padding(
                .bottom,
                max(
                    proxy.safeAreaInsets.top
                        - proxy.safeAreaInsets.bottom,
                    max(8 - proxy.safeAreaInsets.bottom, 0)
                )
            )
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

#Preview {
    TimerView()
}
