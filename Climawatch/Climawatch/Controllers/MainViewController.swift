//
//  MainViewController.swift
//  Climawatch
//
//  Created by William Judd on 10/9/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var fetchedEvents = [Event]()
    
    var weatherDataManager = WeatherData()
    var eventDataMangager = EventManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        weatherDataManager.delegate = self
        eventDataMangager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        eventDataMangager.fetchEvent(cityName: "")
    }
    @IBAction func updateLocationTapped(_ sender: Any) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: Any) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }else{
            textField.placeholder = "Enter City"
            return false
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text {
            weatherDataManager.fetchWeather(cityName: city)
        }        
        searchTextField.text = ""
    }
}


//MARK: - WeatherDataDelegate

extension MainViewController: WeatherDataDelegate {
    func didUpdateWeather(_ weatherData: WeatherData, model: WeatherModel) {
        
        DispatchQueue.main.async {
            self.temperatureLabel.text = model.temperatureString
            self.conditionImageView.image = UIImage(systemName: model.cityCondition)
            self.cityLabel.text = model.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}

//MARK: - EventManagerDelegate

extension MainViewController: EventManagerDelegate {
    func didUpdateEvent(_ eventData: EventManager, model: [Event]) {
        
        DispatchQueue.main.async {
            
            self.fetchedEvents = model
            print(self.fetchedEvents)
            
        }
    }
    
    func eventFailedWithError(error: Error) {
        print(error)
    }
    
}

//MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lon = location.coordinate.longitude
            let lat = location.coordinate.latitude
            weatherDataManager.fetchWeather(longitude: lon, latitude: lat)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}
