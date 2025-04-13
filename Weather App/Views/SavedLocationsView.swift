//
//  SavedLocationsView.swift
//  Weather App
//
//  Created by user268994 on 4/13/25.
//
import SwiftData
import SwiftUI

struct SavedLocationsView: View {
    @Query var favLocations: [SavedLocation]
    @State private var shouldNavigate = false


    var body: some View {
        
        if !favLocations.isEmpty {
            NavigationStack {
                List(favLocations) { location in
                    NavigationLink(value: location) {
                        VStack(alignment: .leading) {
                            Text(location.displayName)
                                .font(.headline)
                            Text("Lat: \(location.lat), Lon: \(location.lon)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Saved Locations")
                .navigationDestination(for: SavedLocation.self) { location in
                    WeatherView(
                        weatherViewModel: WeatherViewModel(),
                        location: Location(
                            locationID: location.id,
                            lat: location.lat,
                            lon: location.lon,
                            name: location.displayName,
                            display_name: location.displayName,
                            address: Address(
                                city: nil,
                                county: nil,
                                state: nil,
                                country: "not saved",
                                country_code: "not saved"
                            )
                        )
                    )
                }
            }
        } else {
            Text("No Saved Locations")
                .font(.title)
                .navigationTitle("Saved Locations")

        }
    }
    
}

#Preview {
    SavedLocationsView()
}

