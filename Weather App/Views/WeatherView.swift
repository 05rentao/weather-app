//
//  WeatherView.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//
import SwiftUI

struct WeatherView : View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    
    let location: Location
    @State private var weatherViewError: Bool = false
    @State private var weatherInfo: WeatherInfo?
    
    init(weatherViewModel: WeatherViewModel, location: Location) {
        self.weatherViewModel = weatherViewModel
        self.location = location
    }
    
    
    var body: some View {
        if weatherViewError {
            ErrorView(message: "weatherViewError")
        } else {
            VStack {
                Text(location.display_name)
                    .font(.title)
                    .padding()
                Spacer()
                Text("TODO: figure out if API call worked and make the weather appear")
                HStack {
                    Text("\(weatherInfo!.data.temperature)")
                    // force unwrap ok because  should already be set to error at the .task at the VStack level
                        .font(.title)
                    Text(weatherInfo!.hourlyUnits.temperature)
                        .font(.subheadline)
                }
                Text("Chance of rain: \(weatherInfo!.data.precipitationProbability) \(weatherInfo!.hourlyUnits.precipitationProbability) ")
                Text("Precipitation: \(weatherInfo!.data.precipitationProbability) \(weatherInfo!.hourlyUnits.precipitation) ")
                Spacer()
            }
            .padding()
            .navigationTitle(location.display_name)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                do {
                    let info = try await weatherViewModel.getWeatherInfo(location: location)
                    self.weatherInfo = info
                } catch {
                    self.weatherViewError = true
                }
            }
            
        }
    }
}

struct ErrorView: View {
    @State var message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.title)
            .padding(.top, 8)
    }
}


#Preview {
    WeatherView(weatherViewModel: WeatherViewModel(), location: Location.mock)
}

