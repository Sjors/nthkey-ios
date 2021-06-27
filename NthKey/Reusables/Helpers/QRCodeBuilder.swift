//
//  QRCodeBuilder.swift
//  QRCodeBuilder
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import UIKit
import CoreImage.CIFilterBuiltins

class QRCodeBuilder {
    
    // For QR code
    // https://www.hackingwithswift.com/books/ios-swiftui/generating-and-scaling-up-a-qr-code
    private static let context = CIContext()
    private static let filter = CIFilter.qrCodeGenerator()

    static func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return nil
    }
    
    static func generateQRCode(from data: Data) -> UIImage? {
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        return generateQRCode(from: string)
    }
    
}
