//
//  ImmersiveView.swift
//  HoopExample
//
//  Created by Allen Wang on 3/2/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @State var hand = HandTrackingModel()
    
    var body: some View {
        RealityView { content in
            let floor = getFloorEntity()
            content.add(floor)
            
            let hoop = await getHoopEntity()
            content.add(hoop)

            let ball = await getBallEntity()
            content.add(ball)

            content.add(hand.rootEntity) // load hand tracking
        }
        .gesture(
            DragGesture(minimumDistance: 200)
            .targetedToAnyEntity()
            .onChanged{ value in
                value.entity.position = value.convert(
                    value.location3D,
                    from: .local,
                    to: value.entity.parent!
                )
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
            }
            .onEnded { value in
                value.entity.position = value.convert(
                    value.location3D,
                    from: .local,
                    to: value.entity.parent!
                )
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                if var physicsMotion = value.entity.components[PhysicsMotionComponent.self] {
                    let translation = value.predictedEndTranslation3D / 1000
                    physicsMotion.linearVelocity = SIMD3<Float>(
                        Float(translation.x),
                        Float(-translation.y),
                        Float(translation.z)
                    )
                    value.entity.components[PhysicsMotionComponent.self] = physicsMotion
                }
            }
        )
        .task {
            await hand.run()
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
