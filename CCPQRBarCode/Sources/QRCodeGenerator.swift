//
//  QRCodeGenerator.swift
//  CCPQRCode
//
//  Created by 储诚鹏 on 2018/6/20.
//  Copyright © 2018年 储诚鹏. All rights reserved.
//

import UIKit

class QRCodeGenerator {
    private let size: CGSize
    private let color: UIColor
    private let info: String
    private let type: CodeType
    
    /*
     * 输出图像编码纠错水平，越高水平代表更大的图像输出，但允许更大的地区代码损坏或模糊
     * L: 7%
     * M: 15% default
     * Q: 25%
     * h: 30%
     */
    enum InputCorrectionLevel: String{
        case L
        case M
        case Q
        case H
    }
    
    enum CodeType: String {
        case qr = "CIQRCodeGenerator"
        case bar = "CICode128BarcodeGenerator"
    }
    
    struct Defaults {
        static let size = CGSize(width: 100, height: 100)
        static let color = UIColor.black
        static let info = "QRCodeGenerator.CCP"
        static let level = InputCorrectionLevel.M.rawValue
        static let block: @convention(c)(UnsafeMutableRawPointer?, UnsafeRawPointer, Int) -> () = { _,_,_ in
            
        }
    }
    
    init(size: CGSize = Defaults.size, color: UIColor = Defaults.color, info: String = Defaults.info, type: CodeType = .qr) {
        self.size = size
        self.color = color
        self.info = info
        self.type = type
    }
    
    private func ciimage() -> CIImage? {
        guard let data = info.data(using: .utf8) else {
            fatalError("invalid string")
        }
        let filter = CIFilter(name: type.rawValue)
        filter?.setValue(data, forKey: "inputMessage")
        if type == .qr {
            filter?.setValue(Defaults.level, forKey: "inputCorrectionLevel")
        }
        else if type == .bar {
            filter?.setValue(0.00, forKey: "inputQuietSpace")
        }
        return filter?.outputImage
    }
    
    private func uiimage() -> UIImage {
        if let ci = ciimage() {
            let rect = ci.extent.integral
            let scale = min(size.width / rect.width, size.height / rect.height)
            let width = rect.width * scale
            let height = rect.height * scale
            let cs = CGColorSpaceCreateDeviceGray()
            let ctx = CIContext()
            let bitMap = ctx.createCGImage(ci, from: rect)!
            let bitMapCtx =  CGContext(
                data: nil,
                width: Int(width),
                height: Int(height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: cs,
                bitmapInfo:
                CGImageAlphaInfo.none.rawValue)!
            bitMapCtx.interpolationQuality = .none
            bitMapCtx.scaleBy(x: scale, y: scale)
            bitMapCtx.draw(bitMap, in: rect)
            let scaleImg = bitMapCtx.makeImage()!
            return UIImage(cgImage: scaleImg)
        }
        fatalError("failed to generate a qrcode image")
    }
    
    public func qrimage() -> UIImage {
        if color == Defaults.color {
            return uiimage()
        }
        return toColor(color, uiimage())
    }
    
}


extension UIImageView {
    func setQRCodeImg(info: String = QRCodeGenerator.Defaults.info, color: UIColor = QRCodeGenerator.Defaults.color, type: QRCodeGenerator.CodeType = .qr) {
        self.image = QRCodeGenerator(color: color, info: info, type: type).qrimage()
    }
}



