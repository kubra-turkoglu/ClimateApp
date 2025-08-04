//
//  WeatherManager.swift
//  ClimateApp
//
//  Created by Kubra Bozdogan on 8/4/25.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError (error: Error)
}
struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=081c9d93943de082cadd451e3da76025&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees ) {
        let urlStringwithcoordinate = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlStringwithcoordinate)
    }
    
    func fetchCityName(weatherData: Data) -> String? {
        return parseJSON(weatherData)?.cityName
    }
    
    func performRequest(with urlString: String) {
        //        1. Create a URL
        if let url = URL(string: urlString) {
            //        2. Create a URLSession
            let session = URLSession( configuration: .default)
            //        3. Give URLSession a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
                
            }
            //        4. Start the task
            task.resume()
        }
    }
    //In order for us to be able to set sth as nil, our WeatherModel has to become an optional.
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
