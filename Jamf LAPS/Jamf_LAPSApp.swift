//
//  Jamf_LAPSApp.swift
//  Jamf LAPS
//
//  Created by Richard Mallion on 04/05/2023.
//

import SwiftUI

@main
struct Jamf_LAPSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 500, maxWidth: 500,
                    minHeight: 500, maxHeight: 500)

        }
        .windowResizability(.contentSize)
    }
}
