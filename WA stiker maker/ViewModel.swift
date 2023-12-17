//
//  ViewModel.swift
//  WA stiker maker
//
//  Created by Rauan Umenov on 17.12.2023.
//

import Foundation
import Observation
import SwiftUI
import CoreImage
import UIKit
import SwiftWebP

@Observable
class ViewModel {
    
    private static let PasteboardStikerPackDataType = "net.whatsapp.third-party.sticker-pack"
    private static let whatsAPPURL = URL(string: "whatsapp://stickerPack")!
    private static let PasteboardExpirationSeconds: TimeInterval = 60
    
    var trayIcon = Stiker(isTrayIcon: true)
    var stikers: [Stiker] = (0...29).map { i in Stiker(pos: i)}
    
    var showOriginalImage = false
    let imageHelper = ImageVisionHelper()
    
    var isAbleToExportAsStikers: Bool {
        let stickersCount = self.stikers.filter {$0.outputImage != nil}.count
        return stickersCount > 2 && trayIcon.outputImage != nil
    }
    
    func onInputImageSelected(_ image: CIImage, stiker: Stiker) {
        let inputCIImage = image
        let inputImage = UIImage(cgImage: imageHelper.render(ciImage: inputCIImage))
        let outputImage = self.removeImageBackground(input: inputCIImage)
        var stiker = stiker
        
        let imageData = ImageData(inputCIImage: inputCIImage, inputImage: inputImage, outputImage: outputImage)
        stiker.state = .selected(imageData)
        
        if stiker.isTrayIcon {
            trayIcon = stiker
        } else {
            stikers[stiker.pos] = stiker
        }
    }
    
    
    func removeImageBackground(input: CIImage) -> UIImage? {
        guard let maskedImage = imageHelper.removeBackground(from: input, croppedToInstanceExtent: true) else {
            return nil
        }
        return UIImage(cgImage: imageHelper.render(ciImage: maskedImage))
    }
    
    func sendToWhatsApp(){
        guard isAbleToExportAsStikers,
              let trayOutputImage = trayIcon.imageData?.outputImage
        else {return}
        
        let outputImageTrayData = trayOutputImage.scaleToFit(targetSize: .init(width: 96, height: 96))
            .scaledPNGData()
        print("Tray bytes size \(outputImageTrayData.count)")
        
        var json: [String: Any] = [:]
        json["identifier"] = "WASMID"
        json["name"] = "WASM"
        json["publisher:"] = "Rauan Umenov"
        json["tray_image"] = outputImageTrayData.base64EncodedString()
        
        var stickersArray: [[String: Any]] = []
        let stickersImage = self.stikers.compactMap {$0.imageData?.outputImage}
        
        for image in stickersImage {
            var stickersDict = [String: Any]()
            let outputPngData = image.scaleToFit(targetSize: .init(width: 512, height: 512))
                .scaledPNGData()
            print("Sticker size \(outputPngData.count)")
            
            if let imageData = WebPEncoder().encodePNG(data: outputPngData) {
                stickersDict["image_data"] = imageData.base64EncodedString()
                stickersDict["emojis"] = ["🤣"]
                stickersArray.append(stickersDict)
            }
        }
        json["Stickers"] = stickersArray
        
        var jsonWithAppStoreLink: [String: Any] = json
        jsonWithAppStoreLink["ios_app_store_link"] = ""
        jsonWithAppStoreLink["android_play_store_link"] = ""
        
        guard let dataToSend = try? JSONSerialization.data(withJSONObject: jsonWithAppStoreLink, options: []) else {return}
        
        let pasteboard = UIPasteboard.general
        pasteboard.setItems([[ViewModel.PasteboardStikerPackDataType: dataToSend]], 
                            options:
                                [UIPasteboard.OptionsKey.localOnly: true,
                                 UIPasteboard.OptionsKey.expirationDate: Date(timeIntervalSinceNow: ViewModel.PasteboardExpirationSeconds)])
    
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!) {
                UIApplication.shared.open(ViewModel.whatsAPPURL)
            }
        }
    }
    
    func updateSticker(_ sticker: Stiker, shouldSwitchToUIThread: Bool = false, updateHandler: (( _ sticker: inout Stiker) -> Void)? = nil) {
            func update() {
                var sticker = sticker
                updateHandler?(&sticker)
                if sticker.isTrayIcon {
                    self.trayIcon = sticker
                } else {
                    self.stikers[sticker.pos] = sticker
                }
            }
            
            if shouldSwitchToUIThread {
                DispatchQueue.main.async { update() }
            } else {
                update()
            }
        }
}
