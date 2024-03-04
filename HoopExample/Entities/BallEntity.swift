//
//  BallEntity.swift
//  HoopExample
//
//  Created by Allen Wang on 3/4/24.
//

import Foundation
import RealityKit


func getBallEntity() async -> ModelEntity {
    let ball = try! await ModelEntity(named: "ball")
    Task { @MainActor in
        ball.scale *= 0.8
        ball.collision = try! await CollisionComponent(shapes: [ShapeResource.generateConvex(from: ball.model!.mesh)])
        ball.components.set(InputTargetComponent())
        ball.components[PhysicsBodyComponent.self] = .init(
            massProperties: .default,
            material: .generate(
                staticFriction: 0.5,
                dynamicFriction: 0.5,
                restitution: 0.5
            ),
            mode: .dynamic
        )
        ball.components[PhysicsMotionComponent.self] = .init()
        ball.position.z -= 1.8
        ball.position.y += 2
    }
    return ball
}
