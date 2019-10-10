//
//  WeatherData.swift
//  Climawatch
//
//  Created by William Judd on 10/10/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import Foundation


struct WeatherData {
    
    let weatherDataURL = "http://api.openweathermap.org/data/2.5/weather?appid=4c77d4f0c775415b96621bbe71a98fae&units=imperial"
    
    func fetchWeather(cityName: String) {
        
        let dataURL = "\(weatherDataURL)&q=\(cityName)"
        print(dataURL)
    }
}
