//
//  QRScan.swift
//  CCPQRCode
//
//  Created by 储诚鹏 on 2018/6/21.
//  Copyright © 2018年 储诚鹏. All rights reserved.
//

import UIKit
import AVFoundation

class QRScan: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let session = AVCaptureSession()
    private let device = AVCaptureDevice.default(for: .video)
    private var drawRect = CGRect.zero
    private let supview: UIView
    private let width: CGFloat
    private let height: CGFloat
    private let descriptionLabel = UILabel()
    private let frame: CGRect
    private let scannerView = UIImageView()
    private let lineView = UIImageView(image: UIImage(named: "line"))
    private let cornerViews
        = ["leftTop", "rightTop", "leftDown", "rightDown"]
            .map { UIImage(named: $0) }
            .map { UIImageView(image: $0) }
    private var isInit = false
    var type: SannerType = .qr {
        didSet {
            if isInit {
                reload()
            }
        }
    }
   
    var getCode: (String) -> ()?
    enum SannerType {
        case qr, bar
    }
    private struct Defaults {
        private static let barCode: [AVMetadataObject.ObjectType]
            = [.upce, .code39, .code39Mod43, .code93, .code128, .ean8, .ean13, .itf14, .interleaved2of5]
        private static let qrCode: [AVMetadataObject.ObjectType]
            = [.qr, .aztec]
        private static let qrBarCode: [AVMetadataObject.ObjectType]
            = [.pdf417]
        
        static let outputTypes = Defaults.barCode + Defaults.qrBarCode + Defaults.qrBarCode
        static let videoGravity: AVLayerVideoGravity = .resizeAspectFill
        static let scanFrameScale: CGFloat = 3.0 / 5.0
        static let descriptionFont = UIFont.systemFont(ofSize: 12)
        static let descriptionColor = UIColor.white
        static let movingDuration: TimeInterval = 2.0
    }
    
    init(supview: UIView, type: SannerType = .qr, frame: CGRect = UIScreen.main.bounds) {
        self.supview = supview
        self.type = type
        self.frame = frame
        width = frame.width
        height = frame.height
        super.init()
        scanView()
        isInit = true
    }
    
    private func scannerCreator() {
        guard let device = device else {
            fatalError("device[AVCaptureDevice] can't be nil")
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError("input[AVCaptureDeviceInput] can't be nil")
        }
        let output = AVCaptureMetadataOutput()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = Defaults.outputTypes
        session.sessionPreset = .high
        let preLayer = AVCaptureVideoPreviewLayer(session: session)
        preLayer.videoGravity = Defaults.videoGravity
        preLayer.frame = frame
        supview.layer.insertSublayer(preLayer, at: 0)
    }
    
    private func qrFrame() -> CGRect {
        let size = min(width, height) * Defaults.scanFrameScale
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        let x = (width - size) / 2
        let y = (height - size) / 2
        return rect.offsetBy(dx: x, dy: y)
    }
    
    private func barFrame() -> CGRect {
        let size = min(width, height) * Defaults.scanFrameScale
        let rect = CGRect(x: 0, y: 0, width: size, height: size / 2)
        let x = (width - size) / 2
        let y = (height - size / 2) / 2
        return rect.offsetBy(dx: x, dy: y)
    }
    
    private func descriptionLabelSet() {
        descriptionLabel.font = Defaults.descriptionFont
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = Defaults.descriptionColor
        supview.addSubview(descriptionLabel)
    }
    
    private func scannerViewImage() -> UIImage? {
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        guard let ctx = context else {
            fatalError("failed to init ctx[CGContextRef]")
        }
        ctx.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        ctx.fill(frame)
        ctx.clear(drawRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func scanView() {
        scannerCreator()
        descriptionLabelSet()
        supview.addSubview(scannerView)
        supview.addSubview(lineView)
        for cornerView in cornerViews {
            supview.addSubview(cornerView)
        }
        reload()
    }
    
    func reload() {
        var text = ""
        if type == .qr {
            drawRect = qrFrame()
            text = "将二维码放入框内，即可自动扫描"
        }
        else {
            drawRect = barFrame()
            text = "将条形码放入框内，即可自动扫描"
        }
        scannerView.image = scannerViewImage()
        descriptionLabel.frame = CGRect(x: drawRect.minX, y: drawRect.maxY + 15, width: drawRect.width, height: 30)
        descriptionLabel.text = text
        for cornerView in cornerViews {
            let idx = cornerViews.index(of: cornerView)!
            let idxX = idx % 2
            let idxY = idx / 2
            cornerView.frame = CGRect(x: drawRect.minX + (drawRect.width - 15) * CGFloat(idxX), y: drawRect.minY + (drawRect.height - 15) * CGFloat(idxY), width: 15, height: 15)
        }
        lineView.frame = CGRect(x: drawRect.minX, y: drawRect.minY, width: drawRect.width, height: 5)
        movingLine()
    }
    
    private func movingLine() {
        lineView.layer.removeAllAnimations()
        UIView.animate(withDuration: Defaults.movingDuration, delay: 0, options: [.repeat, .curveEaseIn], animations: { [unowned self] in
            self.lineView.frame = self.lineView.frame.offsetBy(dx: 0, dy: self.drawRect.height)
        }, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects.first
            metadataObject.stringValue
        }
    }
}
