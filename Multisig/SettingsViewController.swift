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

final class SettingsViewController : UIViewController, UIDocumentPickerDelegate {
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Prompt user to open JSON file if no wallet exists yet
        let types: [String] = [kUTTypeJSON as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        DispatchQueue.main.async {
            self.getTopMostViewController()?.present(documentPicker, animated: true, completion: nil)
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
                NSLog("%@ %@ %@" , xfp, p2wsh_deriv, p2wsh)
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
