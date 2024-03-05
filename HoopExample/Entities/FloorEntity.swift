//
//  FloorEntity.swift
//  HoopExample
//
//  Created by Allen Wang on 3/5/24.
//

import Foundation
import RealityKit

func getFloorEntity() -> Entity {
   let floor = ModelEntity(
       mesh: .generatePlane(width: 20, depth: 20),
       materials: [OcclusionMaterial()]
   )
   floor.generateCollisionShapes(recursive: false)
   floor.components[PhysicsBodyComponent.self] = .init(
       massProperties: .default,
       mode: .static
   )
   return floor
}
