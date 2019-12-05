//
//  SettingsViewController.swift
//  SettingsViewController
//
//  Created by Sjors Provoost on 04/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import UIKit
import MobileCoreServices
import LibWally

final class SettingsViewController : UIViewController, UIDocumentPickerDelegate {
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Prompt user to open JSON file if no wallet exists yet
        let defaults = UserDefaults.standard
        if let encodedCosigners = defaults.array(forKey: "cosigners") {
            if encodedCosigners.isEmpty {
                print("Unexpected empty cosigners array")
                return
            }
            let encodedCosigner = encodedCosigners[0] as! Data
            let cosigner = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encodedCosigner)!
            print("Cosigner: " + cosigner.fingerprint.hexString.uppercased())

        } else {
            let types: [String] = [kUTTypeJSON as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            
            DispatchQueue.main.async {
                self.getTopMostViewController()?.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        
        var topMostViewController = keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if (urls.count != 1) {
            NSLog("Please select 1 JSON file")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: urls[0].path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, String>,
                let xfp = jsonResult["xfp"],
                let p2wsh_deriv = jsonResult["p2wsh_deriv"],
                let p2wsh = jsonResult["p2wsh"]
            {
                let vpub = Data(base58: p2wsh)!
                let vpubMarker = Data("02575483")! // Vpub (testnet, p2wsh, public)
                if (vpub.subdata(in: 0..<4) != vpubMarker) {
                    NSLog("Expected Vpub marker 0x%@, got 0x%@", vpubMarker.hexString, vpub.subdata(in: 0..<4).hexString)
                    return
                }
                let p2wsh_tpub = Data("043587cf")! + vpub.subdata(in: 4..<vpub.count)
                let cosigner = Signer(fingerprint: Data(xfp)!, derivation: BIP32Path(p2wsh_deriv)!, hdKey: HDKey(p2wsh_tpub.base58)!)
                let encoded = try! NSKeyedArchiver.archivedData(withRootObject: cosigner, requiringSecureCoding: true)
                let defaults = UserDefaults.standard
                defaults.set([encoded], forKey: "cosigners")
                defaults.set(2, forKey: "threshold")
                NSLog("Cosigner %@ added" , xfp)
            }
        } catch {
            NSLog("Something went wrong parsing JSON file")
            return
        }
        NSLog("Restart app to see first wallet address")
    }

}

extension SettingsViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = SettingsViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SettingsViewController>) -> SettingsViewController.UIViewControllerType {
        return SettingsViewController()
    }

    func updateUIViewController(_ uiViewController: SettingsViewController.UIViewControllerType, context: UIViewControllerRepresentableContext<SettingsViewController>) {
    }
    
}
