//
//  QrCodeGenerator.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 14/02/2026.
//

import UIKit
import QRCode
import SwiftUI

struct QrCodeGenerator {
    func generateQRCode(from string: String) -> UIImage? {
        do {
            let cgImage = try QRCode.build
               .text(string)
               .quietZonePixelCount(3)
               .foregroundColor(Colors.highlight.cgColor!)
               .backgroundColor(Color.black.cgColor!)
               .onPixels.shape(QRCode.PixelShape.CurvePixel())
               .eye.shape(QRCode.EyeShape.Squircle())
               .logo(image: UIImage(named: "QRCodeLogo")!.cgImage!)
               .errorCorrection(.high)
               .generate.image(dimension: 600)
            
            return UIImage(cgImage: cgImage)
        }
        catch {
            return nil
        }
    }
}
