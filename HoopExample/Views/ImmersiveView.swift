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

            let floor = ModelEntity(
                mesh: .generatePlane(width: 10, depth: 10),
                materials: [OcclusionMaterial()]
            )
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
            )
            content.add(floor)

            let ball = await getBallEntity()
            content.add(ball)
            
            let hoop = await getHoopEntity()
            content.add(hoop)
            
            content.add(hand.rootEntity) // load hand tracking
        }
        .gesture(
            DragGesture()
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
