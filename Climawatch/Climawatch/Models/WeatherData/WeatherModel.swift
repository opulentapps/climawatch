//
//  WeatherModel.swift
//  Climawatch
//
//  Created by William Judd on 10/12/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import Foundation

struct WeatherModel {
    let cityName: String
    let cityTemp: Double
    let cityId: Int
    
    var temperatureString : String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: cityTemp)
        formatter.minimumIntegerDigits = 0
        return String(formatter.string(from: number) ?? "")
    }
    
    var cityCondition: String {
        switch cityId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}
