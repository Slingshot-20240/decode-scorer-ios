//
//  Kickoff.swift
//  DECODE
//
//  Created by Jining Liu on 10/3/25.
//

import SwiftUI

struct KickoffEventView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var eventSheet: EventSheet?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .bottom) {
                        Image(
                            "MarketingIcon\(colorScheme == .light ? "Light" : "Dark")"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(height: 64)
                        .shadow(radius: 16)

                        Spacer()

                        Image("SlingshotLabel")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                            .colorInvert(colorScheme == .light)
                    }
                    .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Thank you for using our app.")
                            .font(.title)

                        Text("We wish you a fun and successful season!")
                    }

                    Text("The ultimate scorer, **redefined.**")
                        .font(.title3)

                    Text(
                        "Used by roboticists across 30+ countries during the INTO THE DEEP℠ season, we are excited to release the DECODE™ Scorer presented by 20240 Slingshot. The ultimate scorer, redefined for the 2025-2026 *FIRST*® Tech Challenge season."
                    )

                    Text(
                        "You've never seen a scorer like this before. With full game scoring and saving, history & stats, a built-in full-screen timer, assignable teams in matches, Motif randomization, and a basic calculator mode for when you just want to do a quick score, the DECODE scorer presented by 20240 Slingshot is the ultimate scoring app for FTC."
                    )

                    Text(
                        "*FIRST*®, *FIRST*® Tech Challenge, FTC®, *FIRST*® AGE™, DECODE™, and all accompanying logos as they are created, are trademarks of For Inspiration and Recognition of Science and Technology (*FIRST*®) (www.firstinspires.org). These trademarks are used by special permission of *FIRST* which is not overseeing, involved with, or responsible for this activity, product, or service. © 2025 *FIRST*®. Used by special permission. All rights reserved."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding([.horizontal, .bottom])
            }
            .background {
                Image(.decodeBackground)
                    .opacity(colorScheme == .light ? 0.5 : 0.2)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        eventSheet = nil
                    }
                }
            }
        }
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    ProgressView()
        .sheet(isPresented: .constant(true)) {
            KickoffEventView(eventSheet: .constant(.kickoff))
        }
}
