//
//  WeatherView.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//
import SwiftUI
import SwiftData

struct WeatherView : View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @Environment(\.modelContext) private var modelContext
    
    let location: Location
    @State private var weatherViewError: Bool = false
    @State private var weatherInfo: WeatherInfo?
    @State private var index : Int?
    @Query var favLocations: [SavedLocation]

    
    init(weatherViewModel: WeatherViewModel, location: Location) {
        self.weatherViewModel = weatherViewModel
        self.location = location
    }
    
    
    var body: some View {
        if weatherViewError {
            ErrorView(message: "weatherViewError")
        } else {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Text(location.display_name)
                            .font(.title)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        

                    if let info = weatherInfo, let i = index {
                        HStack {
                            let temp = info.data.temperature[i]
                            Text(temp.truncatingRemainder(dividingBy: 1) == 0
                                 ? "\(Int(temp))"
                                 : String(format: "%.1f", temp)
                            )
                            .font(.system(size: geometry.size.height * 0.15, weight: .bold))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .shadow(radius: 5)
                            .foregroundStyle(.primary)
                            
                            Text(info.hourlyUnits.temperature)
                                .font(.headline)
                        }
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)) // Apply custom padding values
                        
                        
                        VStack {
                            Text("Chance of rain: \(info.data.precipitationProbability[i]) \(info.hourlyUnits.precipitationProbability)")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let precip = info.data.precipitation[i]
                            let precipTrunc = precip.truncatingRemainder(dividingBy: 1) == 0
                            ? "\(Int(precip))"
                            : String(format: "%.1f", precip)
                            
                            Text("Precipitation: \(precipTrunc) \(info.hourlyUnits.precipitation)")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 50, bottom: 50, trailing: 20)) // Apply custom padding values
                        
                        
                        VStack {
                            let id = "\(location.lat)_\(location.lon)"
                            if favLocations.contains(where: { $0.id == id } ) {
                                Button("Unsave Location", systemImage: "star.fill") {
                                    if let toDelete = favLocations.first(where: { $0.id == id }) {
                                        modelContext.delete(toDelete)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Button("Save Location", systemImage: "star") {
                                    modelContext.insert(SavedLocation(lat: location.lat, lon: location.lon, displayName: location.display_name))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 50, bottom: 50, trailing: 20)) // Apply custom padding values
                        Spacer()
                    } else {
                        ProgressView("Loading weather...")
                    }
                }
                .padding()
                .navigationTitle("Current Weather")
                .navigationBarTitleDisplayMode(.large)
                .task {
                    do {
                        let info = try await weatherViewModel.getWeatherInfo(location: location)
                        let index: Int = try weatherViewModel.getCurrWeatherIndex(weatherInfo: info)
                        self.weatherInfo = info
                        self.index = index
                    } catch {
                        self.weatherViewError = true
                    }
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

