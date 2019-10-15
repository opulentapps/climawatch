//
//  EventData.swift
//  Climawatch
//
//  Created by William Judd on 10/14/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import Foundation

struct EventData: Codable {
    let results: [Event]
}

struct Event: Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    
}
