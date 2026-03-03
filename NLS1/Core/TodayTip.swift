//
//  TodayTip.swift
//  NLS1
//

import Foundation

enum TodayTip {
    private static let tips: [String] = [
        "Watch lane gaps before they reach you. Shift early, not at the last moment.",
        "Pulse shots work best in rhythm. Wait for the reticle, then tap.",
        "Overdrive refills when you hit targets in sequence. Save it for dense waves.",
        "Bramble Gates block one lane. Plan your path two moves ahead.",
        "Shade Drones move in patterns. Learn one pattern per run.",
        "Flux Orbs drift slowly. Use them to time your lane changes.",
        "Training drills improve lane reading. Replay them to beat your score.",
        "Clean dodges build Charge. One hit resets the streak.",
    ]

    static var current: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return tips[day % tips.count]
    }
}
