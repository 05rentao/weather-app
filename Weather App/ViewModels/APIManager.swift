//
//  APIManager.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//

import Foundation

class APIManager {
    static let instance = APIManager()
    
    let baseURLGeocoding = "https://nominatim.openstreetmap.org/search?"
    let baseURLWeather = "https://api.open-meteo.com/v1/forecast?"
    // asdjasdad
    
    enum NetworkError: String, Error {
        case networkError
        case invalidURL
    }
    
// sample query7 https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m,precipitation_probability&timezone=America%2FNew_York&forecast_days=1&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch
    
    func getLocation(query: String) async throws -> Location {
        var components = URLComponents(string: "https://nominatim.openstreetmap.org/search?")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query), // URLQueryItem auto changes the string to match url format
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: "1"), // limits to only result that best matches query
            URLQueryItem(name: "addressdetails", value: "1"),
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            throw NetworkError.networkError
        }
        
        let results = try JSONDecoder().decode([Location].self, from: data)
        // TODO: decoder is failing right here
        
        // Nominatim returns an array of locations
        guard let location = results.first else {
            throw NetworkError.networkError
        }

        return location
    }
    
    
    
    func getWeatherInfo(lat: Double, lon: Double) async throws -> WeatherInfo {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast?")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
            URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,precipitation"),
            URLQueryItem(name: "timezone", value: "America/New_York"),
            URLQueryItem(name: "forecast_days", value: "1"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "precipitation_unit", value: "inch")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
          
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Not an HTTP response")
            throw NetworkError.networkError
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad status code: \(httpResponse.statusCode)")
            print("URL: \(url)")
            print("Headers: \(httpResponse.allHeaderFields)")
            print("Response body:\n", String(data: data, encoding: .utf8) ?? "nil")
            throw NetworkError.networkError
        }

        
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
//            print("error https response: APIManager: getWeatherInfo()")
//            throw NetworkError.networkError
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // or use .current if needed
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        //
        do {
            return try decoder.decode(WeatherInfo.self, from: data)
        } catch let error {
            print("Decoding failed: \(error)")
            print("JSON:\n", String(data: data, encoding: .utf8) ?? "nil")
            throw error
        }
        // decoder returns an WeatherInfo object WITH an WeatherData field
    }
    
    
}

extension DateFormatter {
    static let iso8601withTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = .current  // device's local time
        return formatter
    }()
}


