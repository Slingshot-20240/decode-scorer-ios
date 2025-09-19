//
//  ContentView.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import Aptabase
import SwiFTC
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var showGameScoreView: Bool = false
    @State private var showAutoTuningView: Bool = false
    @State private var showDriverPracticeView: Bool = false
    @State private var showEndgamePracticeView: Bool = false
    @State private var showHistoryView: Bool = false
    @State private var showTimerView: Bool = false
    @State private var showCalculatorView: Bool = false
    @State private var showSettings: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            FractionalStack(.vertical, divisions: 15, elements: 4, spacing: 8) {
                fd in
                Button {
                    Haptics.play(.light)
                    Analytics.shared.updateTotals()
                    showHistoryView = true
                    Analytics.shared.trackFeature(.hna)
                } label: {
                    HStack {
                        VStack(spacing: -2) {
                            Image(systemName: "clock.fill")
                                .padding(.trailing, 28)
                            Image(systemName: "function")
                                .padding(.leading, 28)
                        }
                        .font(.title2)

                        Text("History & Analysis")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .minimumScaleFactor(0.6)
                    .padding()
                    .maxArea()
                    .background(.decodeOrange.gradient)
                    .radius(16)
                    .useDeviceCornerRadius(
                        [.topLeading],
                        fallback: 24,
                        subtract: 8
                    )
                }
                .tint(.white)
                .frame(height: fd.divs(6))

                HStack(spacing: 8) {
                    Button {
                        Haptics.play(.light)
                        showTimerView = true
                        Analytics.shared.trackFeature(.timer)
                    } label: {
                        HStack {
                            Image(systemName: "timer")
                                .font(.title2)

                            Text("Timer")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .minimumScaleFactor(0.6)
                        .padding()
                        .maxArea()
                        .background(.decodeGold.gradient)
                        .radius(16)
                    }
                    .tint(.white)

                    Button {
                        Haptics.play(.light)
                        showCalculatorView = true
                        Analytics.shared.trackFeature(.calc)
                    } label: {
                        HStack {
                            Image(systemName: "plus.slash.minus")
                                .font(.title2)

                            Text("Calculator")
                                .font(.title)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .minimumScaleFactor(0.6)
                        .padding()
                        .maxArea()
                        .background(.decodeGreen.gradient)
                        .radius(16)
                    }
                    .tint(.white)
                }
                .frame(height: fd.divs(4))

                HStack {
                    (Text("🏜️ ")
                        + Text("DECODE")
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        + Text(" Scorer"))
                        .font(.title)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, fd.divs(1) / 3 * 2)
                        .padding(.vertical, fd.divs(1) / 3)
                        .maxArea(alignment: .leading)
                        .glassBackground(
                            shape: RoundedRectangle(cornerRadius: 16)
                        )

                    GeometryReader { proxy in
                        Link(
                            destination: URL(
                                string:
                                    "https://github.com/Slingshot-20240/decode-scorer-ios"
                            )!
                        ) {
                            Image("GitHub")
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                                .frame(
                                    width: proxy.size.height,
                                    height: proxy.size.height
                                )
                                .glassBackground(
                                    shape: RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .tint(.clear)
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
                .frame(height: fd.divs(2))

                HStack(spacing: 8) {
                    Button {
                        Haptics.play(.light)
                        showSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                                .font(.title3)

                            Text("Settings")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .minimumScaleFactor(0.6)
                        .padding()
                        .maxArea()
                        .background(.decodeBlue.gradient)
                        .radius(16)
                        .useDeviceCornerRadius(
                            [.bottomLeading],
                            fallback: 24,
                            subtract: 8
                        )
                    }
                    .tint(.white)

                    Image("SlingshotLabel")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, fd.divs(1) / 2)
                        .padding(.vertical, fd.divs(1) / 3)
                        .background(.slingshotPurple.gradient)
                        .radius(16)
                }
                .frame(height: fd.divs(3))
            }

            FractionalStack(.vertical, divisions: 4, elements: 2, spacing: 8) {
                fd in
                Button {
                    Haptics.play(.light)
                    showGameScoreView = true
                    Analytics.shared.trackFeature(.game)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.largeTitle)

                        Text("New Game")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    .minimumScaleFactor(0.6)
                    .padding()
                    .maxArea()
                    .background(.firstRed.gradient)
                    .radius(16)
                    .useDeviceCornerRadius(
                        [.topTrailing, .bottomTrailing],
                        fallback: 24,
                        subtract: 8
                    )
                    //                    .useDeviceCornerRadius(
                    //                        [.topTrailing],
                    //                        fallback: 24,
                    //                        subtract: 8
                    //                    )
                }
                .tint(.white)
                //                .frame(height: fd.divs(3))
                //
                //                Menu {
                //                    Button("Auto Tuning", systemImage: "autostartstop") {
                //                        Haptics.play(.light)
                //                        showAutoTuningView = true
                //                        Analytics.shared.trackFeature(.auto)
                //                    }
                //                    .tint(.blue)
                //
                //                    Button("Driver Practice", systemImage: "steeringwheel") {
                //                        Haptics.play(.light)
                //                        showDriverPracticeView = true
                //                        Analytics.shared.trackFeature(.dp)
                //                    }
                //                    .tint(.blue)
                //
                //                    Button("Endgame Practice", systemImage: "timer") {
                //                        Haptics.play(.light)
                //                        showEndgamePracticeView = true
                //                        Analytics.shared.trackFeature(.ep)
                //                    }
                //                    .tint(.blue)
                //                } label: {
                //                    HStack {
                //                        VStack(spacing: -2) {
                //                            Image(systemName: "apple.terminal.fill")
                //                                .padding(.trailing, 28)
                //                            Image(systemName: "steeringwheel")
                //                                .padding(.leading, 28)
                //                        }
                //                        .font(.title2)
                //
                //                        Text("Tuning & Practice")
                //                            .font(.title)
                //                            .fontWeight(.semibold)
                //                    }
                //                    .minimumScaleFactor(0.6)
                //                    .padding()
                //                    .maxArea()
                //                    .background(.firstBlue.gradient)
                //                    .radius(16)
                //                    .useDeviceCornerRadius(
                //                        [.bottomTrailing],
                //                        fallback: 24,
                //                        subtract: 8
                //                    )
                //                }
                //                .menuOrder(.fixed)
                //                .tint(.white)
                //                .frame(height: fd.divs(1))
            }
        }
        .fullScreenPadding()
        .fullScreenCover(isPresented: $showGameScoreView) {
            GameScoreView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
                .modelContext(modelContext)
        }
        .fullScreenCover(isPresented: $showAutoTuningView) {
            AutoTuningView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
                .modelContext(modelContext)
        }
        .fullScreenCover(isPresented: $showDriverPracticeView) {
            DriverPracticeView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
                .modelContext(modelContext)
        }
        .fullScreenCover(isPresented: $showEndgamePracticeView) {
            EndgamePracticeView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
                .modelContext(modelContext)
        }
        .sheet(isPresented: $showHistoryView) {
            HistoryView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
                .modelContext(modelContext)
        }
        .fullScreenCover(isPresented: $showTimerView) {
            TimerView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
        }
        .fullScreenCover(isPresented: $showCalculatorView) {
            CalculatorView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .background(Color.primary.colorInvert().ignoresSafeArea())
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DecodeGameModel.self, inMemory: true)
}
