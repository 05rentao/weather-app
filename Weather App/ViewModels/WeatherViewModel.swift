//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//
import Foundation
import SwiftData

@MainActor
class WeatherViewModel : ObservableObject {
    
    @Published var currLocation: Location?
    // everytime open a specific location has value, if at home screen no value

    init() {
        // can initialize each save location as we go, no need to init at start
    }
    
    // for getting weather from queries
    func getWeather(query: String) async throws -> WeatherInfo {
        let loc: Location = try await findCoodinate(query: query)
        return try await getWeatherInfo(location: loc)
    }
    
    // for getting weather for save locations
    func getWeatherInfo(location: Location) async throws -> WeatherInfo {
        do {
            return try await APIManager.instance.getWeatherInfo(lat:location.lat, lon: location.lon)
        } catch let error {
            print("getWeatherInfo: APIManager.getWeatherInfo(lat:\(location.lat), lon: \(location.lon)) error")
            throw error
        }
    }
    
//    // save the current location (currLocation) for future reference
//    func saveLocation() {
//        let saved = SavedLocation(lat: currLocation.lat, lon: currLocation.lon, displayName: currLocation.display_name)
//        favLocations.append(saved)
//    }
//    
//    // remove the current location (currLocation)
//    func removeSavedLocation() {
//        favLocations.removeAll { $0.id == "\(currLocation.lat)_\(currLocation.lon)" }
//    }
    
    
    // ======================= helper funcs for getting weather =============================
    
    func findCoodinate(query: String) async throws -> Location {
        do {
            return try await APIManager.instance.getLocation(query: query)
        } catch let error {
            print("findCoodinate error")
            throw error
        }
    }
    
    
    // get the index for curr hour to reference
    func getCurrWeatherIndex(weatherInfo: WeatherInfo) throws -> Int {
        do {
            let now = Date()
            
            // use same timezone as the API
            let calendar = Calendar(identifier: .gregorian)
            let roundedNow = calendar.date(bySetting: .minute, value: 0, of: now)!
            
            guard let index = weatherInfo.data.time.firstIndex(where: { calendar.isDate($0, equalTo: roundedNow, toGranularity: .hour )}) else {
                throw WeatherAppErrors.weatherFetchError
            }
            return index
        } catch let error {
            print("getCurrWeatherIndex: date rounded error")
            throw error
        }
    }
    
    enum WeatherAppErrors: Error {
        case weatherFetchError
    }
    
}

