//
//  MainViewController.swift
//  Climawatch
//
//  Created by William Judd on 10/9/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import UIKit
import CoreLocation
import NVActivityIndicatorView


class MainViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var indicatorView: UIView!
    
    var weatherDataManager = WeatherData()
    var eventDataMangager = EventManager()
    let locationManager = CLLocationManager()
    
    fileprivate var fetchedEvents = [Event]()
    
    fileprivate let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: cv.frame.width + 15, bottom: 0, right: 0)
        layout.minimumLineSpacing = 15
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        searchTextField.delegate = self
        weatherDataManager.delegate = self
        eventDataMangager.delegate = self
        locationManager.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let height = UIScreen.main.bounds.height
        
        // Loading Spinner
        indicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballBeat)
        startAnimating()
        
        // CollectionView
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        let bgImage = UIImageView();
        bgImage.image = UIImage(named: "blue_Curve");
        bgImage.contentMode = .scaleToFill
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundView = bgImage
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: height / 2.15).isActive = true
        
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
            self.stopAnimating()
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
            eventDataMangager.fetchEvent(longitude: lon, latitude: lat)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - CollectionViewDelegate & DataSource

extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                return CGSize(width: collectionView.frame.width/2.0, height: collectionView.frame.height - 50)
            case 1334:
                print("iPhone 6/6S/7/8")
                return CGSize(width: collectionView.frame.width/2.0, height: collectionView.frame.height - 50)
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                return CGSize(width: collectionView.frame.width/2.0, height: collectionView.frame.height - 50)
            default:
                print("Unknown")
            }
        }
        return CGSize(width: collectionView.frame.width/2.0, height: collectionView.frame.height - 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.fetchedEvents.count)
        return self.fetchedEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.4
        cell.data = self.fetchedEvents[indexPath.item]
        return cell
    }
}

class CustomCell: UICollectionViewCell {
    
    var data: Event? {
        didSet {
            guard let data = data else { return }
            title.text = data.title
            eventCategory.text = data.category.capitalizingFirstLetter()
            
            switch data.category {
            case "public-holidays":
                return bg.image = #imageLiteral(resourceName: "holiday_card")
            case "politics":
                return bg.image = #imageLiteral(resourceName: "politics_card")
            case "concerts":
                return bg.image = #imageLiteral(resourceName: "concert_card")
            case "sports":
                return bg.image = #imageLiteral(resourceName: "sports_card")
            case "conferences":
                return bg.image = #imageLiteral(resourceName: "conference_card")
            case "observances":
                return bg.image = #imageLiteral(resourceName: "religion_card")
            case "school-holidays":
                return bg.image = #imageLiteral(resourceName: "school_card")
            default:
                return bg.image = #imageLiteral(resourceName: "holiday_card")
            }
            
        }
    }
    
    
    fileprivate let title: UILabel = {
        let iv = UILabel()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.lineBreakMode = .byWordWrapping
        iv.numberOfLines = 2
        iv.font = UIFont(name: "Helvetica", size: 16)
        iv.textColor = UIColor(rgb: 0x353B50)
        return iv
    }()
    
    fileprivate let eventCategory: UILabel = {
        let category = UILabel()
        category.translatesAutoresizingMaskIntoConstraints = false
        category.clipsToBounds = true
        category.lineBreakMode = .byWordWrapping
        category.numberOfLines = 2
        category.font = UIFont(name: "Helvetica", size: 14)
        category.textColor = UIColor(rgb: 0x4A90E2)
        return category
    }()
    
    
    fileprivate let bg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .white
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(bg)
        contentView.addSubview(title)
        contentView.addSubview(eventCategory)
        
        bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        eventCategory.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -5).isActive = true
        eventCategory.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        eventCategory.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

