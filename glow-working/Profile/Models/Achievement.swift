//
//  Achievement.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import Foundation

struct Achievement: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    var isUnlocked: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}
