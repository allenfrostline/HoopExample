//
//  ContentView.swift
//  HoopExample
//
//  Created by Allen Wang on 3/2/24.
//

import ARKit
import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @EnvironmentObject var model: ImmersiveModel
    
    var body: some View {
        Text("Hoop Example")
        Toggle("Enter Immersive View", isOn: Binding(get: {
            model.immersiveSpaceId != nil
        }, set: { value in
            Task {
                if value {
                    let immersiveSpaceId: String = "ImmersiveSpace"
                    model.immersiveSpaceId = immersiveSpaceId
                    await openImmersiveSpace(id: immersiveSpaceId)
                } else {
                    model.immersiveSpaceId = nil
                    await dismissImmersiveSpace()
                }
            }
        }))
        .toggleStyle(.button)
    }
}

#Preview {
    ContentView()
}
