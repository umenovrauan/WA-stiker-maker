//
//  Models.swift
//  WA stiker maker
//
//  Created by Rauan Umenov on 17.12.2023.
//

import Foundation
import Observation
import CoreImage
import UIKit
import SwiftUI

enum StikerState {
    case none
    case selected(ImageData)
}

struct ImageData {
    var inputCIImage: CIImage?
    var inputImage: UIImage
    var outputImage: UIImage?
}

struct Stiker: Identifiable {
    
    let id = UUID()
    var pos: Int = 0
    var state = StikerState.none
    var isTrayIcon = false
    
    var imageData: ImageData? {
        if case let .selected(imageData) = state {
            return imageData
        }
        return nil
    }
    
    var inputImage: Image? {
        guard let imageData else { return nil}
        return Image(uiImage: imageData.inputImage)
    }
    
    var outputImage: Image? {
        guard let imageData, let outputImage = imageData.outputImage else {return nil}
        return Image(uiImage: outputImage)
    }
}
