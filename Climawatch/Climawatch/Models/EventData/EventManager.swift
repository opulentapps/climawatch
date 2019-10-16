//
//  EventManager.swift
//  Climawatch
//
//  Created by William Judd on 10/14/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import Foundation

protocol EventManagerDelegate {
    
    func didUpdateEvent(_ eventData: EventManager, model: [Event])
    func eventFailedWithError(error: Error)
}

class EventManager: ObservableObject {
    
    @Published var events = [Event]()
    
    let eventDataURL = "https://api.predicthq.com/v1/events?within=10km@37.785834,-122.406417"
    
    var delegate: EventManagerDelegate?
    
    func fetchEvent(cityName: String) {
        let dataURL = "\(eventDataURL)"
        fetchData(dataUrl: dataURL)
        print(dataURL)
    }
    
    func fetchData(dataUrl: String) {
        if let url = URL(string: dataUrl) {
            
            let config = URLSessionConfiguration.default
            let authValue: String? = "Bearer \("fzKxlvVsXUDy_y9ZIG5gGRb0a7AmFKQTq0dZqwnJ")"
            config.httpAdditionalHeaders = ["Authorization" : authValue ?? ""]
            let session = URLSession(configuration: config)
            
            
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.eventFailedWithError(error: error!)
                    return
                }
                let decoder = JSONDecoder()
                if let returnData = data {
                    
                    do {
                        let results = try decoder.decode(EventData.self, from: returnData)
                        self.events = results.results
                        self.delegate?.didUpdateEvent(self, model: self.events)
                    }catch{
                        self.delegate?.eventFailedWithError(error: error)
                    }
                    
                }
            }
            dataTask.resume()
        }
    }
    
    //: END
}
