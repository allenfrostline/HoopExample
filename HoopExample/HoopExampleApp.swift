//
//  HoopExampleApp.swift
//  HoopExample
//
//  Created by Allen Wang on 3/2/24.
//

import SwiftUI

@main
struct HoopExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
