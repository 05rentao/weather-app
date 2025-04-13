//
//  ContentView.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var favLocations: [SavedLocation] = []
    @StateObject var weatherViewModel: WeatherViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedLocation: Location?
    @State private var locationQuery: String = ""
    @State private var errorFindingLoc: Bool = false
    @State private var shouldNavigate = false
    @State private var sheetPresented = false
    

    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Image(systemName: "cloud.sun.rain.circle.fill")
                        .font(.system(size: geometry.size.height * 0.15, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundStyle(.tint)
                    Text("Find Weather for:")
                        .font(.title)
                    TextField(
                        "location",
                        text: $locationQuery
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                    .textFieldStyle(.roundedBorder)
                    Button("Submit") {
                        Task {
                            do {
                                let loc = try await weatherViewModel.findCoodinate(query: locationQuery)
                                self.selectedLocation = loc
                                self.shouldNavigate = true
                                self.errorFindingLoc = false
                            } catch {
                                self.selectedLocation = nil
                                self.shouldNavigate = false
                                self.errorFindingLoc = true
                                print("ContentView: Failed to find location: \(error)")
                            }
                            
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(locationQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    
                    // Show error message at bottom if needed
                    if errorFindingLoc {
                        Text("error finding location from given query")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 8)
                    }
                    Spacer()
                    Button("Saved Locations") {
                        sheetPresented.toggle()
                    }
                    .sheet(isPresented: $sheetPresented) {
                        SavedLocationsView()
                    }
                }
                .padding()
                .navigationDestination(isPresented: $shouldNavigate) {
                    if let location = selectedLocation {
                        WeatherView(
                            weatherViewModel: self.weatherViewModel,
                            location: location)
                    } else {
                        // this branch usually won't be hit, but it's required
                        Text("error getting WeatherView")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(weatherViewModel: WeatherViewModel())
        .modelContainer(for: SavedLocation.self)
}
