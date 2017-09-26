//
//  ScanQrViewController.swift
//
//  Copyright (c) 2017 CM Telecom B.V.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import AVFoundation
import AuthenticatorSDK

class ScanQrViewController: UIViewController {

    // MARK: - Properties
    
    let captureSession = AVCaptureSession()
    var stopScanning = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("Scan QR code", comment: "")
        
        setupQrReader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestCameraAuthorizationStatus { (status) in
            if status  == .authorized {
                self.startReading()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopReading()
    }
    
    // MARK: - QR Reader
    
    func setupQrReader() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            debugPrint("No capture device available")
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            debugPrint("Error while adding capture device input")
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let bounds = self.view.layer.bounds
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.bounds = bounds
        videoPreviewLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        self.view.layer.addSublayer(videoPreviewLayer)
        
        let output = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
    }
    
    func startReading() {
        self.captureSession.startRunning()
    }
    
    func stopReading() {
        self.captureSession.stopRunning()
    }
    
    func processScanResult(result: String) {
        let scanResult = QrCodeScanResult(result: result)
        
        guard let environmentId = scanResult.environmentId, let deviceSecret = scanResult.deviceEnvironmentSecret else {
            let alert = UIAlertController(
                title: NSLocalizedString("Invalid QR Code", comment: ""),
                message: NSLocalizedString("You have scanned an invalid QR code", comment: ""),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (_) in
                self.stopScanning = false
            }))

            self.present(alert, animated: true, completion: nil)
            return
        }
        
        authenticator.environmentClient.register(id: environmentId, deviceSecret: deviceSecret) { (error) in
            if error == nil {
                appSettings.environmentId = environmentId
                appSettings.deviceSecret = deviceSecret
                
                let alert = UIAlertController(
                    title: NSLocalizedString("Success", comment: ""),
                    message: NSLocalizedString("The QR code has been registered", comment: ""),
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("QR Error", comment: ""),
                    message: NSLocalizedString("Could not register the QR code. Please check your connection and try again.", comment: ""),
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (_) in
                    self.stopScanning = false
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func requestCameraAuthorizationStatus(completion: @escaping (AVAuthorizationStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        completion(.authorized)
                    } else {
                        completion(.denied)
                    }
                }
            }
        } else {
            completion(status)
        }
    }
}

extension ScanQrViewController: AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - QR reader delegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !stopScanning else {
            return
        }
        
        for data in metadataObjects {
            guard let metaData = data as? AVMetadataMachineReadableCodeObject,
                metaData.type == AVMetadataObject.ObjectType.qr,
                let result = metaData.stringValue else {
                    continue
            }
            
            stopScanning = true
            self.processScanResult(result: result)
        }
    }
}
