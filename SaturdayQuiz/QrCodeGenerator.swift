//
//  QrCodeGenerator.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 14/02/2026.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

struct QrCodeGenerator {
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
