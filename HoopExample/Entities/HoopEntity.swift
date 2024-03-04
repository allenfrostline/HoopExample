//
//  HoopEntity.swift
//  HoopExample
//
//  Created by Allen Wang on 3/2/24.
//

import SwiftUI
import Foundation
import RealityKit
import RealityGeometries

// extend UIColor to accept HEX colors
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(
           red: CGFloat(red) / 255.0,
           green: CGFloat(green) / 255.0,
           blue: CGFloat(blue) / 255.0,
           alpha: 1.0
       )
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

@MainActor
// generate a hoop-shaped ModelEntity
func getHoopEntity() async -> ModelEntity {
    var glassMaterial = PhysicallyBasedMaterial()
    glassMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint:.white)
    glassMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.2)
    glassMaterial.blending = .transparent(opacity: .init(floatLiteral: 0.1))
    
    var steelMaterial = PhysicallyBasedMaterial()
    steelMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint:UIColor(rgb: 0xb8471d))
    steelMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
    steelMaterial.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.7)
    
    var rubberMaterial = PhysicallyBasedMaterial()
    rubberMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint:UIColor(rgb: 0xb8471d))
    rubberMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
    
    var stripMaterial = PhysicallyBasedMaterial()
    stripMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint:.white)
    stripMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1)

    let hoop = ModelEntity()
    hoop.name = "hoop"
    
    let shapeData = generateTorusShapeData(sides: 64, csSides: 64, radius: 0.23, csRadius: 0.012)
    let rim = await ModelEntity(
        mesh: try! RealityGeometry.generateTorus(sides: 64, csSides: 64, radius: 0.23, csRadius: 0.012),
        materials: [steelMaterial],
        collisionShape: try! ShapeResource.generateStaticMesh(positions: shapeData.0, faceIndices: shapeData.1),
        mass: 0
    )
    rim.orientation = simd_quatf(angle: .pi / 2, axis: [1,0,0])
    rim.scale.z = 2
    rim.name = "rim"
    
    let rimBridge = ModelEntity(
        mesh: .generateBox(width: 0.13, height: 0.115, depth: 0.01, cornerRadius: 0.005),
        materials: [steelMaterial]
    )
    rimBridge.position.y -= 0.29
    rim.addChild(rimBridge)
    
    let rimWedge = ModelEntity(
        mesh: .generateBox(width: 0.09, height: 0.115, depth: 0.01),
        materials: [steelMaterial]
    )
    rimWedge.orientation = simd_quatf(angle: -.pi / 30, axis: [1,0,0])
    rimWedge.position.y = -0.29
    rimWedge.position.z = 0.005
    rim.addChild(rimWedge)
    
    let rimWedge2 = ModelEntity(
        mesh: .generateBox(width: 0.09, height: 0.115, depth: 0.01),
        materials: [steelMaterial]
    )
    rimWedge2.orientation = simd_quatf(angle: -.pi / 25, axis: [1,0,0])
    rimWedge2.position.y = -0.29
    rimWedge2.position.z = 0.01
    rim.addChild(rimWedge2)
    
    let rimWedge3 = ModelEntity(
        mesh: .generateBox(width: 0.09, height: 0.03, depth: 0.03),
        materials: [steelMaterial]
    )
    rimWedge3.orientation = simd_quatf(angle: -.pi / 22, axis: [1,0,0])
    rimWedge3.position.y = -0.33
    rimWedge3.position.z = 0.015
    rim.addChild(rimWedge3)

    rim.position.z += 0.35
    rim.position.y += 0.01
    hoop.addChild(rim)

    // backboard: 1.83 x 1.22 x 0.02 with strips of width 0.05
    let backboard = ModelEntity(
        mesh: .generateBox(width: 1.83, height: 1.22, depth: 0.019),
        materials: [glassMaterial],
        collisionShapes: [ShapeResource.generateBox(width: 1.83, height: 1.22, depth: 0.019)],
        mass: 0
    )
    backboard.name = "backboard"

    let topOuterStrip = ModelEntity(
        mesh: .generateBox(width: 1.83, height: 0.05, depth: 0.001),
        materials: [stripMaterial]
    )
    let bottomOuterStrip = ModelEntity(
        mesh: .generateBox(width: 1.83, height: 0.05, depth: 0.001),
        materials: [stripMaterial]
    )
    let leftOuterStrip = ModelEntity(
        mesh: .generateBox(width: 0.05, height: 1.12, depth: 0.001),
        materials: [stripMaterial]
    )
    let rightOuterStrip = ModelEntity(
        mesh: .generateBox(width: 0.05, height: 1.12, depth: 0.001),
        materials: [stripMaterial]
    )
    topOuterStrip.position.y += 0.585
    topOuterStrip.position.z += 0.01
    bottomOuterStrip.position.y -= 0.585
    bottomOuterStrip.position.z += 0.01
    leftOuterStrip.position.x -= 0.89
    leftOuterStrip.position.z += 0.01
    rightOuterStrip.position.x += 0.89
    rightOuterStrip.position.z += 0.01
    backboard.addChild(topOuterStrip)
    backboard.addChild(bottomOuterStrip)
    backboard.addChild(leftOuterStrip)
    backboard.addChild(rightOuterStrip)
    
    let topInnerStrip = ModelEntity(
        mesh: .generateBox(width: 0.59, height: 0.05, depth: 0.001),
        materials: [stripMaterial]
    )
    let bottomInnerStrip = ModelEntity(
        mesh: .generateBox(width: 0.59, height: 0.05, depth: 0.001),
        materials: [stripMaterial]
    )
    let leftInnerStrip = ModelEntity(
        mesh: .generateBox(width: 0.05, height: 0.35, depth: 0.001),
        materials: [stripMaterial]
    )
    let rightInnerStrip = ModelEntity(
        mesh: .generateBox(width: 0.05, height: 0.35, depth: 0.001),
        materials: [stripMaterial]
    )
    topInnerStrip.position.y += 0.1
    topInnerStrip.position.z += 0.01
    bottomInnerStrip.position.y -= 0.3
    bottomInnerStrip.position.z += 0.01
    leftInnerStrip.position.x -= 0.27
    leftInnerStrip.position.y -= 0.1
    leftInnerStrip.position.z += 0.01
    rightInnerStrip.position.x += 0.27
    rightInnerStrip.position.y -= 0.1
    rightInnerStrip.position.z += 0.01
    backboard.addChild(topInnerStrip)
    backboard.addChild(bottomInnerStrip)
    backboard.addChild(leftInnerStrip)
    backboard.addChild(rightInnerStrip)
    
    let topLeftCornerVertical = ModelEntity(
        mesh: .generateBox(width: 0.08, height: 0.16, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let topLeftCornerHorizontal = ModelEntity(
        mesh: .generateBox(width: 0.2, height: 0.08, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let topRightCornerVertical = ModelEntity(
        mesh: .generateBox(width: 0.08, height: 0.16, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let topRightCornerHorizontal = ModelEntity(
        mesh: .generateBox(width: 0.2, height: 0.08, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let bottomLeftCornerVertical = ModelEntity(
        mesh: .generateBox(width: 0.08, height: 0.16, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let bottomLeftCornerHorizontal = ModelEntity(
        mesh: .generateBox(width: 0.2, height: 0.08, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let bottomRightCornerVertical = ModelEntity(
        mesh: .generateBox(width: 0.08, height: 0.16, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    let bottomRightCornerHorizontal = ModelEntity(
        mesh: .generateBox(width: 0.2, height: 0.08, depth: 0.03, cornerRadius: 0.015),
        materials: [rubberMaterial]
    )
    topLeftCornerVertical.position.x -= 0.89
    topLeftCornerVertical.position.y += 0.545
    topLeftCornerHorizontal.position.x -= 0.83
    topLeftCornerHorizontal.position.y += 0.585
    topRightCornerVertical.position.x += 0.89
    topRightCornerVertical.position.y += 0.545
    topRightCornerHorizontal.position.x += 0.83
    topRightCornerHorizontal.position.y += 0.585
    bottomLeftCornerVertical.position.x -= 0.89
    bottomLeftCornerVertical.position.y -= 0.545
    bottomLeftCornerHorizontal.position.x -= 0.83
    bottomLeftCornerHorizontal.position.y -= 0.585
    bottomRightCornerVertical.position.x += 0.89
    bottomRightCornerVertical.position.y -= 0.545
    bottomRightCornerHorizontal.position.x += 0.83
    bottomRightCornerHorizontal.position.y -= 0.585
    backboard.addChild(topLeftCornerVertical)
    backboard.addChild(topLeftCornerHorizontal)
    backboard.addChild(topRightCornerVertical)
    backboard.addChild(topRightCornerHorizontal)
    backboard.addChild(bottomLeftCornerVertical)
    backboard.addChild(bottomLeftCornerHorizontal)
    backboard.addChild(bottomRightCornerVertical)
    backboard.addChild(bottomRightCornerHorizontal)
    
    backboard.position.y = 0.29
    
    hoop.addChild(backboard)
    
    Task { @MainActor in
        hoop.scale /= 1.5
        hoop.components.set(InputTargetComponent())
        hoop.components[PhysicsBodyComponent.self] = .init(
            massProperties: .default,
            material: .generate(
                staticFriction: 0.5,
                dynamicFriction: 0.5,
                restitution: 0.05
            ),
            mode: .static
        )
        hoop.components[PhysicsMotionComponent.self] = .init()
        hoop.position.z -= 2
        hoop.position.y += 1.5
    }
    return hoop
}


func addTorusVertices(
    _ radius: Float, _ csRadius: Float, _ sides: Int, _ csSides: Int
) -> [SIMD3<Float>] {
    let angleIncs = 360 / Float(sides)
    let csAngleIncs = 360 / Float(csSides)
    var allVertices: [SIMD3<Float>] = []
    var currentradius: Float
    var jAngle: Float = 0
    var iAngle: Float = 0
    let dToR: Float = .pi / 180
    var zval: Float
    while jAngle <= 360 {
        currentradius = radius + (csRadius * cosf(jAngle * dToR))
        zval = csRadius * sinf(jAngle * dToR)
        iAngle = 0
        while iAngle <= 360 {
            let vertexPos: SIMD3<Float> = [
                currentradius * cosf(iAngle * dToR),
                currentradius * sinf(iAngle * dToR),
                zval
            ]
            var uv: SIMD2<Float> = [1 - iAngle / 360, 2 * jAngle / 360 - 1]
            if uv.y < 0 { uv.y *= -1 }
            allVertices.append(vertexPos)
            iAngle += angleIncs
        }
        jAngle += csAngleIncs
    }
    return allVertices
}

func generateTorusShapeData(
    sides: Int, csSides: Int, radius: Float, csRadius: Float
) -> ([SIMD3<Float>], [UInt16]) {
    let allVertices = addTorusVertices(radius, csRadius, sides, csSides)

    var indices: [UInt16] = []
    var i = 0
    let rowCount = sides + 1
    while i < csSides {
        var j = 0
        while j < sides {
            /*
             1
             |\
             | \
             2--3
             */
            indices.append(UInt16(i * rowCount + j))
            indices.append(UInt16(i * rowCount + j + 1))
            indices.append(UInt16((i + 1) * rowCount + j + 1))
            /*
             3--2
              \ |
               \|
                1
             */
            indices.append(UInt16((i + 1) * rowCount + j + 1))
            indices.append(UInt16((i + 1) * rowCount + j))
            indices.append(UInt16(i * rowCount + j))
            j += 1
        }
        i += 1
    }
    return (allVertices, indices)
}
