//
//  WeatherModel.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//

import Foundation
import SwiftData


struct WeatherInfo: Decodable {
    let hourlyUnits: HourlyUnits
    let data: WeatherData
    let timezone: String
    
    enum CodingKeys: String, CodingKey {
        case hourlyUnits = "hourly_units"
        case data = "hourly"
        case timezone
    }
    
}

struct HourlyUnits: Decodable {
    let temperature: String
    let precipitationProbability: String
    let precipitation: String

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case precipitation
    }
}

struct WeatherData: Decodable {
    let time: [Date]
    let temperature: [Double]
    let precipitationProbability: [Int]
    let precipitation: [Double]
    

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case precipitation
    }
}



struct Location: Identifiable, Decodable, Hashable {
    let locationID: String
    let lat: Double
    let lon: Double
    let name: String
    let display_name: String
    let address: Address

    var id: String { "\(lat)_\(lon)" }

    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case name
        case display_name
        case address
    }

    // init generate locationID when decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        name = try container.decode(String.self, forKey: .name)
        display_name = try container.decode(String.self, forKey: .display_name)
        address = try container.decode(Address.self, forKey: .address)
        locationID = UUID().uuidString // Auto-generate if not in JSON
    }

    // manual init
    init(locationID: String = UUID().uuidString, lat: Double, lon: Double, name: String, display_name: String, address: Address) {
        self.locationID = locationID
        self.lat = lat
        self.lon = lon
        self.name = name
        self.display_name = display_name
        self.address = address
    }
}


extension Location {
    static let mock = Location(lat: 39.9527237, lon: -75.1635262,
                               name: "Philadelphia",
                               display_name: "Philadelphia, Philadelphia County, Pennsylvania, United States",
                               address:
                                Address(
                                    city: "Philadelphia",
                                    county: "Philadelphia County",
                                    state: "Pennsylvania",
                                    country: "United States",
                                    country_code: "us")
    )
}

struct Address: Decodable, Hashable {
    let city: String?
    let county: String?
    let state: String?
    let country: String
    let country_code: String
}

@Model
class SavedLocation {
    @Attribute(.unique) var id: String
    var lat: Double
    var lon: Double
    var displayName: String

    init(lat: Double, lon: Double, displayName: String) {
        self.id = "\(lat)_\(lon)"
        self.lat = lat
        self.lon = lon
        self.displayName = displayName
    }
}
