//
//  QRCodeViewController.swift
//  QRCodeScanner
//
//  Created by Stas Dashkevich on 13.03.22.
//

import Foundation
import UIKit

class QRCodeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    let searchWebMenuButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1910547316, green: 0.1472589374, blue: 0.1568871737, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(presentUI), for: .touchUpInside)
        return button
    }()
    
    @objc func presentUI() {
        let vc = QRCodeScannerViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    func setup(){
        
        view.addSubview(searchWebMenuButton)
        
        NSLayoutConstraint.activate([
            searchWebMenuButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchWebMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchWebMenuButton.widthAnchor.constraint(equalToConstant: 100),
            searchWebMenuButton.heightAnchor.constraint(equalToConstant: 100),
        
        ])
    }
    
}
