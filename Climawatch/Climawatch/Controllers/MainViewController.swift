//
//  MainViewController.swift
//  Climawatch
//
//  Created by William Judd on 10/9/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate, WeatherDataDelegate {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherDataManager = WeatherData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        weatherDataManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
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
        // Add search weather functionality here if not empty
        print(searchTextField.text!)

        if let city = searchTextField.text {
            weatherDataManager.fetchWeather(cityName: city)
        }
        
        
        searchTextField.text = ""
    }
    
    func didUpdateWeather(model: WeatherModel) {
        print(model.temperatureString)
        
        
    }
    
}
