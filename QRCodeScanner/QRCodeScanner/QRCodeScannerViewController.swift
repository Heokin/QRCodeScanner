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
        setupCamera()
        createConstraints()
        setupMenuNotHiden()
       
    }
    
    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
          
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            
        } catch {
            print(error)
            return
        }
    }
    
    func createConstraints() {
        qrCodeFrameView = UIView()
        
        if let qrcodeFrameView = qrCodeFrameView {
            view.addSubview(qrcodeFrameView)
            view.bringSubviewToFront(qrcodeFrameView)
            view.addSubview(buttonMenu)
            view.bringSubviewToFront(buttonMenu)
            view.addSubview(labelOutlet)
            view.bringSubviewToFront(labelOutlet)
            buttonMenu.translatesAutoresizingMaskIntoConstraints = false
            labelOutlet.translatesAutoresizingMaskIntoConstraints = false
            qrcodeFrameView.layer.borderColor = UIColor.systemRed.cgColor
            qrcodeFrameView.layer.borderWidth = 3
            NSLayoutConstraint.activate([
                labelOutlet.bottomAnchor.constraint(equalTo: qrcodeFrameView.bottomAnchor, constant: 90),
                labelOutlet.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
                labelOutlet.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
                labelOutlet.heightAnchor.constraint(equalToConstant: 70),
                
                buttonMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
                buttonMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                buttonMenu.widthAnchor.constraint(equalToConstant: 60),
                buttonMenu.heightAnchor.constraint(equalToConstant: 60)
            ])
        } else {
            labelOutlet.isHidden = true
            NSLayoutConstraint.activate([
                labelOutlet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 900),
                labelOutlet.heightAnchor.constraint(equalToConstant: 70)
            ])

        }
    }
    
    //MARK: - Create UI
    let labelOutlet: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.858478725, green: 0.7204294801, blue: 0.06100670248, alpha: 1)
        label.tintColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 14
        label.isHidden = true
        return label
    }()

let buttonMenu: UIButton = {
    let button = UIButton()
    button.backgroundColor = #colorLiteral(red: 0.858478725, green: 0.7204294801, blue: 0.06100670248, alpha: 1)
    button.tintColor = .white
    button.isHidden = true
    button.layer.cornerRadius = 14
    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(ButtonTaped), for: .touchUpInside)
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
    let largeBoldDoc = UIImage(systemName: "qrcode.viewfinder", withConfiguration: largeConfig)
    button.setImage(largeBoldDoc, for: .normal)
    return button
}()
    
@objc func ButtonTaped() {
    let menuInteraction = UIContextMenuInteraction(delegate: self)
    buttonMenu.addInteraction(menuInteraction)
//    menuView.isHidden = false
//    searchWebMenuButton.isHidden = false
//    copyMenuButton.isHidden = false
//    urlLAbelOutlet.isHidden = false
//    urlLAbelOutlet.text = urlHunter
}
    
    let menuView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    let copyMenuButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1910547316, green: 0.1472589374, blue: 0.1568871737, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    let searchWebMenuButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1910547316, green: 0.1472589374, blue: 0.1568871737, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    let urlLAbelOutlet: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.1910547316, green: 0.1472589374, blue: 0.1568871737, alpha: 1)
        label.tintColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
//    func setupMenuWhileHiden() {
//        view.addSubview(menuView)
//        NSLayoutConstraint.activate([
//            menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
//            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            menuView.widthAnchor.constraint(equalToConstant: 10),
//            menuView.heightAnchor.constraint(equalToConstant: 10)
//        ])
//    }
    
    func setupMenuNotHiden() {
        print("tapedMenu")
        view.addSubview(menuView)
        view.addSubview(copyMenuButton)
        view.addSubview(searchWebMenuButton)
        view.addSubview(urlLAbelOutlet)
        menuView.isHidden = true
        searchWebMenuButton.isHidden = true
        copyMenuButton.isHidden = true
        urlLAbelOutlet.isHidden = true
        NSLayoutConstraint.activate([
            menuView.bottomAnchor.constraint(equalTo: buttonMenu.topAnchor, constant: -20),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuView.widthAnchor.constraint(equalToConstant: 280),
            menuView.heightAnchor.constraint(equalToConstant: 150),
            
            searchWebMenuButton.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            searchWebMenuButton.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            searchWebMenuButton.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            searchWebMenuButton.heightAnchor.constraint(equalToConstant: 40),
            
            copyMenuButton.bottomAnchor.constraint(equalTo: searchWebMenuButton.topAnchor, constant: -0.5),
            copyMenuButton.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            copyMenuButton.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            copyMenuButton.heightAnchor.constraint(equalToConstant: 40),
            
            urlLAbelOutlet.bottomAnchor.constraint(equalTo: copyMenuButton.topAnchor, constant: -0.5),
            urlLAbelOutlet.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            urlLAbelOutlet.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            urlLAbelOutlet.topAnchor.constraint(equalTo: menuView.topAnchor)
            
            
        ])
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

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                labelOutlet.isHidden = false
                buttonMenu.isHidden = false
                urlHunter = metadataObj.stringValue!
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "safari.fill")

                let fullString = NSMutableAttributedString(string: "")
                fullString.append(NSAttributedString(attachment: imageAttachment))
                fullString.append(NSAttributedString(string: "Search  "))
                fullString.append(NSAttributedString(string: "\(urlHunter)"))
                labelOutlet.attributedText = fullString
                
            }
            
            if metadataObj.stringValue == nil {
                labelOutlet.isHidden = true
                buttonMenu.isHidden = true
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

extension UIButton {

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }

}
