//
//  UserAchievement.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import Foundation
import FirebaseFirestore

struct UserAchievement: Codable {
    let title: String
    let description: String
    let dateEarned: Timestamp
    let type: String
}
