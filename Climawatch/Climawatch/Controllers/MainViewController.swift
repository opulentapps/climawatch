//
//  MainViewController.swift
//  Climawatch
//
//  Created by William Judd on 10/9/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import UIKit
import CoreLocation


//struct EventData {
//    var title: String
//    var url: String
//    var backgroundImage: UIImage
//}



class MainViewController: UIViewController {
    
    
//    fileprivate let data = [
//        CustomData(title: "The Islands!", url: "maxcodes.io/enroll", backgroundImage: #imageLiteral(resourceName: "background")),
//        CustomData(title: "Subscribe to maxcodes boiiii!", url: "maxcodes.io/courses", backgroundImage: #imageLiteral(resourceName: "background")),
//        CustomData(title: "StoreKit Course!", url: "maxcodes.io/courses", backgroundImage: #imageLiteral(resourceName: "background")),
//        CustomData(title: "Collection Views!", url: "maxcodes.io/courses", backgroundImage: #imageLiteral(resourceName: "blue_bg3")),
//        CustomData(title: "MapKit!", url: "maxcodes.io/courses", backgroundImage: #imageLiteral(resourceName: "background")),
//    ]
    
    
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    fileprivate var fetchedEvents = [Event]()
    
    var weatherDataManager = WeatherData()
    var eventDataMangager = EventManager()
    let locationManager = CLLocationManager()
    
    
    fileprivate let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        searchTextField.delegate = self
        weatherDataManager.delegate = self
        eventDataMangager.delegate = self
        locationManager.delegate = self
        collectionView.delegate = self
                      collectionView.dataSource = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        eventDataMangager.fetchEvent(cityName: "")
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
       
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: view.frame.width/1.5).isActive = true
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
            
            self.collectionView.reloadData()
//            self.cityLabel.text = self.fetchedEvents[1].title
//            print(self.fetchedEvents.count)
            
            
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

//MARK: - CollectionViewDelegate & DataSource

extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       print(self.fetchedEvents.count)
        return self.fetchedEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
//        cell.backgroundColor = .red
        cell.data = self.fetchedEvents[indexPath.item]
        return cell
    }
}

class CustomCell: UICollectionViewCell {
    
        var data: Event? {
            didSet {
                guard let data = data else { return }
//                bg.image = data.backgroundImage
                title.text = data.title
                print(data.title)

            }
        }
    
    
    fileprivate let title: UILabel = {
        let iv = UILabel()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.textColor = .black
        return iv
    }()
    
    
    fileprivate let bg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .white
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(bg)
        contentView.addSubview(title)
        
        bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

