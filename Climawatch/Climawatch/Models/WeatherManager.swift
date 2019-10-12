//
//  WeatherManager.swift
//  Climawatch
//
//  Created by William Judd on 10/12/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import Foundation

struct WeatherManager: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
    
}
