//
//  Weather_AppApp.swift
//  Weather App
//
//  Created by user268994 on 4/11/25.
//

import SwiftUI

@main
struct Weather_App: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView(weatherViewModel: WeatherViewModel())
                .modelContainer(for: SavedLocation.self)
        }
    }
}
