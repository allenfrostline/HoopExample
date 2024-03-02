//
//  ImmersiveModel.swift
//  HoopExample
//
//  Created by Allen Wang on 3/2/24.
//

import Foundation

class ImmersiveModel: ObservableObject {
    @Published var immersiveSpaceId: String? = nil
    @Published var windowId: String? = nil
}
