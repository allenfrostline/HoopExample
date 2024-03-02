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

            let ball = try! await ModelEntity(named: "ball")
            ball.scale *= 0.8
            ball.generateCollisionShapes(recursive: false)
            ball.components.set(InputTargetComponent())
            ball.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                material: .generate(
                    staticFriction: 0.5,
                    dynamicFriction: 0.5,
                    restitution: 0.01
                ),
                mode: .static
            )
            ball.components[PhysicsMotionComponent.self] = .init()
            ball.position.z -= 1.8
            ball.position.y += 2
            content.add(ball)
            
            let hoop = getHoopEntity()
            hoop.scale /= 1.5
            hoop.generateCollisionShapes(recursive: false)
            hoop.components.set(InputTargetComponent())
            hoop.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                material: .generate(
                    staticFriction: 0.5,
                    dynamicFriction: 0.5,
                    restitution: 0.01
                ),
                mode: .static
            )
            hoop.components[PhysicsMotionComponent.self] = .init()
            hoop.position.z -= 2
            hoop.position.y += 1.5
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
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
            }
        )
        .task {
            await hand.run()
        }
        .task {
            await hand.monitorSessionEvents()
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
