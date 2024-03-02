//
//  HoopExampleApp.swift
//  HoopExample
//
//  Created by Allen Wang on 3/2/24.
//

import SwiftUI

@main
struct HoopExampleApp: App {
    @State var immersiveModel: ImmersiveModel = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(immersiveModel)
        }
        .windowStyle(.plain)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
