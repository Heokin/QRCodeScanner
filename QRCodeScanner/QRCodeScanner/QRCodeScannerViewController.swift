//
//  QRCodeScannerViewController.swift
//  QRCodeScanner
//
//  Created by Stas Dashkevich on 13.03.22.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

//struct Menu<Label, Content> where Label : View, Content : View {
//    Menu {
//
//    }
//}

class QRCodeScannerViewController: UIViewController, UIContextMenuInteractionDelegate {
    
    var urlHunter: String = ""
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubviewToFront(buttonPresent)
            
            // Initialize QR Code Frame to highlight the QR Code
            qrCodeFrameView = UIView()
            if let qrcodeFrameView = qrCodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.systemRed.cgColor
                qrcodeFrameView.layer.borderWidth = 3
                view.addSubview(qrcodeFrameView)
                view.bringSubviewToFront(qrcodeFrameView)
                buttonPresent.isHidden = false
                view.addSubview(buttonMenu)
                view.bringSubviewToFront(buttonMenu)
                buttonMenu.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(buttonPresent)
                view.bringSubviewToFront(buttonPresent)
                buttonPresent.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
//                    buttonPresent.bottomAnchor.constraint(equalTo: qrCodeFrameView?.bottomAnchor ?? view.bottomAnchor, constant: 8),
                    buttonPresent.bottomAnchor.constraint(equalTo: qrcodeFrameView.bottomAnchor, constant: 90),
                    buttonPresent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
                    buttonPresent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
                    buttonPresent.heightAnchor.constraint(equalToConstant: 70),
                    
                    buttonMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    buttonMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    buttonMenu.widthAnchor.constraint(equalToConstant: 60),
                    buttonMenu.heightAnchor.constraint(equalToConstant: 60)
                ])
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue anymore
            print(error)
            return
        }
    }
    
    
    //MARK: - Create UI
    let buttonPresent: UILabel = {
        let button = UILabel()
        button.backgroundColor = #colorLiteral(red: 0.858478725, green: 0.7204294801, blue: 0.06100670248, alpha: 1)
        button.tintColor = .white
        button.layer.cornerRadius = 14
        button.isHidden = true
//        button.titleLabel?.font = .systemFont(ofSize: 10)
//        button.addTarget(self, action: #selector(ButtonTaped), for: .touchUpInside)
        return button
    }()
    
//    @objc func ButtonTaped() {
//        let url = URL(string: urlHunter)
//
//        guard url != nil else {return}
//
//        UIApplication.shared.open(url!)
//    }
//}

let buttonMenu: UIButton = {
    let button = UIButton()
    button.backgroundColor = #colorLiteral(red: 0.858478725, green: 0.7204294801, blue: 0.06100670248, alpha: 1)
    button.tintColor = .white
    button.layer.cornerRadius = 14
    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(ButtonTaped), for: .touchUpInside)
    return button
}()
    
@objc func ButtonTaped() {
    let menuInteraction = UIContextMenuInteraction(delegate: self)
    buttonMenu.addInteraction(menuInteraction)
}
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let v = self.view.window!.subviews(ofType:UIVisualEffectView.self)
                if let v = v.first {
                    v.alpha = 0
                }
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _  in
                let copy = UIAction(title: "Copy", image: UIImage(systemName: "safari")) { _ in
                    
                }
                let copy1 = UIAction(title: "Search Web", image: UIImage(systemName: "doc.on.doc")) { _ in
                    
                }
           return UIMenu(title: self.urlHunter, children: [copy, copy1])
        }
    }
    
    
}

// MARK: - SwiftUI
import SwiftUI

struct ScannerVcProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = QRCodeScannerViewController()
        
        func makeUIViewController(context: Context) ->  QRCodeScannerViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            
            return
        }
        
        // Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                urlHunter = metadataObj.stringValue!
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "safari.fill")

                // If you want to enable Color in the SF Symbols.
                let fullString = NSMutableAttributedString(string: "")
                fullString.append(NSAttributedString(attachment: imageAttachment))
                fullString.append(NSAttributedString(string: "Search  "))
                fullString.append(NSAttributedString(string: "\(urlHunter)"))
                buttonPresent.attributedText = fullString
                
            }
            
            if metadataObj.stringValue == nil {
                buttonPresent.isHidden = true
            }
        }
    }
}

extension UIView {
    func subviews<T:UIView>(ofType WhatType:T.Type,
        recursing:Bool = true) -> [T] {
            var result = self.subviews.compactMap {$0 as? T}
            guard recursing else { return result }
            for sub in self.subviews {
                result.append(contentsOf: sub.subviews(ofType:WhatType))
            }
            return result
    }
}
