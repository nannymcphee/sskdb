//
//  GlassesViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 01/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import GLKit

private let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(-.pi * 0.5))
extension GlassesViewController {
    func bufferToImage(sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let originalImage = CIImage(
            cvPixelBuffer: pixelBuffer,
            options: [
                CIImageOption.colorSpace: NSNull()
            ]
        )
        
        let rotatedImage = originalImage.transformed(by: rotationTransform)
        
        return rotatedImage
    }
    func bufferToFilter(sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let orgImage = bufferToImage(sampleBuffer: sampleBuffer) else {
            return nil
        }
        
        guard let filter = CIFilter(name: "CIColorControls") else {
            return nil
        }
        
        filter.setValuesForKeys([kCIInputBrightnessKey:0.0, kCIInputContrastKey:1.1, kCIInputSaturationKey:0.0])
        filter.setValue(orgImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        return outputImage
    }
    func imageFilter(image:UIImage) -> UIImage? {
        guard let ciImage = CIImage.init(image: image) else {
            return nil
        }
        
        guard let filter = CIFilter(name: "CIColorControls") else {
            return nil
        }
        
        let rotatedImage = ciImage.transformed(by: rotationTransform)
        
        filter.setValuesForKeys([kCIInputBrightnessKey:0.0, kCIInputContrastKey:1.1, kCIInputSaturationKey:0.0])
        filter.setValue(rotatedImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        let resultImage = UIImage.init(cgImage: cgImage)
        
        return resultImage
    }
}
extension GlassesViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let drawableWidth = glView.drawableWidth;
        let drawableHeight = glView.drawableHeight;
        
        let drawFrame = CGRect(x: 0, y: 0, width: drawableWidth, height: drawableHeight)
        
        if self.isFilter == false {
            guard let image = bufferToImage(sampleBuffer: sampleBuffer) else {
                return
            }
            context.draw(image, in: drawFrame, from: image.extent)
        } else {
            guard let image = bufferToFilter(sampleBuffer: sampleBuffer) else {
                return
            }
            context.draw(image, in: drawFrame, from: image.extent)
        }
        
        glView.display()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

class GlassesViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var labelZoomLevel: UILabel!
    
    @IBOutlet weak var buttonBlackWhite: UIButton!
    
    var photoOutput: AVCapturePhotoOutput = {
        let o = AVCapturePhotoOutput()
        o.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
        return o
    }()
    private let videoDataOutputQueue: DispatchQueue = DispatchQueue(label: "VideoDataOutputQueue")
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let l = AVCaptureVideoPreviewLayer(session: session)
        l.videoGravity = .resizeAspectFill
        return l
    }()
    public let captureDevice: AVCaptureDevice? = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    private lazy var session: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = .inputPriority
        return s
    }()
    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let v = AVCaptureVideoDataOutput()
        v.alwaysDiscardsLateVideoFrames = true
        v.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        v.connection(with: .video)?.isEnabled = true
        return v
    }()
    
    
    @IBOutlet weak var glView: GLKView!
    private var context: CIContext!
    private var filter: CIFilter = {
        var f = CIFilter(name: "CIColorControls")
        f!.setValuesForKeys([kCIInputBrightnessKey:0.0, kCIInputContrastKey:1.1, kCIInputSaturationKey:0.0])
        return f!
    }()
    var isFilter = false
    
    var resultCallback: ((UIImage)->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.slider.setThumbImage(UIImage.init(named: "ic_reading_glasses_point"), for: .normal)
        self.slider.setThumbImage(UIImage.init(named: "ic_reading_glasses_point"), for: .highlighted)
        
        // GL context
        let glContext = EAGLContext(api: .openGLES2)
        glView.context = glContext!
        glView.enableSetNeedsDisplay = false
        context = CIContext(
            eaglContext: glContext!,
            options: [
                CIContextOption.outputColorSpace: NSNull(),
                CIContextOption.workingColorSpace: NSNull(),
            ]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.beginSesstion()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        }
        if session.isRunning == false {
            session.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        session.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.viewCamera.bounds
    }
    
    func beginSesstion() {
        do {
            guard let captureDevice = captureDevice else {
                fatalError("Camera doesn't work on the simulator! You have to test this on an actual device!")
            }
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            }
            
            self.viewCamera.layer.masksToBounds = true
            self.viewCamera.layer.addSublayer(previewLayer)
            
            self.previewLayer.frame = self.viewCamera.bounds
            session.startRunning()
        } catch let error {
            debugPrint("\(self.self): \(#function) line: \(#line).  \(error.localizedDescription)")
        }
        
        zoom(zoom: 3.0)
    }
    
    func zoom(zoom:CGFloat) {
        do {
            guard let captureDevice = captureDevice else {
                fatalError("Camera doesn't work on the simulator! You have to test this on an actual device!")
            }
            try captureDevice.lockForConfiguration()
            let zoomFactor:CGFloat = zoom
            captureDevice.videoZoomFactor = zoomFactor
            captureDevice.unlockForConfiguration()
        } catch let error {
            debugPrint("\(self.self): \(#function) line: \(#line).  \(error.localizedDescription)")
        }
    }
    
    func flash(on:Bool) {
        guard let captureDevice = captureDevice else {
            fatalError("Camera doesn't work on the simulator! You have to test this on an actual device!")
        }
        if (captureDevice.hasTorch) {
            do {
                try captureDevice.lockForConfiguration()
                if (captureDevice.torchMode == AVCaptureDevice.TorchMode.on) {
                    captureDevice.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try captureDevice.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                captureDevice.unlockForConfiguration()
            } catch {
                debugPrint("\(self.self): \(#function) line: \(#line).  \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Action
    @IBAction func actionSliderValueChanged(_ sender: UISlider) {
        let _value:CGFloat = CGFloat(roundf(sender.value * 2.0) * 0.5)
        self.labelZoomLevel.text = String(format: "%.1f", arguments: [_value])
        
        zoom(zoom: _value)
    }
    
    @IBAction func actionFlashButton(_ sender: Any) {
        flash(on: true)
    }
    
    @IBAction func actionBlackWhiteButton(_ sender: UIButton) {
        self.isFilter = !self.isFilter
    }
    
    @IBAction func actionPreviewButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        self.resultCallback = { (image) in
            let vc:ClassesPreViewController = UIStoryboard(name: "Glasses", bundle: nil).instantiateViewController(withIdentifier: "ClassesPreViewController") as! ClassesPreViewController
            vc.image = image
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func actionCaptureButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        self.resultCallback = { (image) in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    @IBAction func actionOutPageButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionCaptureSaveButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        self.resultCallback = { (image) in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension GlassesViewController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            debugPrint("\(self.self): \(#function) line: \(#line).  \(error.localizedDescription)")
            return
        } else {
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
                guard let image = UIImage.init(data: dataImage) else {
                    return
                }
                var lastImage:UIImage? = nil
                if self.isFilter {
                    lastImage = imageFilter(image: image)
                } else {
                    lastImage = image
                }
                if let image = lastImage {
                    if let cb = self.resultCallback {
                        cb(image)
                    }
                }
            }
            else {
            }
        }
    }
}
