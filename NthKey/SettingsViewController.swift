//
//  SettingsViewController.swift
//  SettingsViewController
//
//  Created by Sjors Provoost on 04/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import UIKit
import LibWally

final class SettingsViewController : UIViewController, UIDocumentPickerDelegate {
    
    var activeFileViewControllerManager: FileViewControllerManager?
    
    override func viewDidLoad() {
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        precondition(activeFileViewControllerManager != nil)
        activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
        activeFileViewControllerManager = nil
    }
    
    func exportPublicKey() {
        precondition(activeFileViewControllerManager == nil)
        precondition(UserDefaults.standard.data(forKey: "masterKeyFingerprint") != nil)
        activeFileViewControllerManager = FileViewControllerManager(task: .savePublicKey)
        activeFileViewControllerManager!.prompt(vc: self)
    }
    
    func exportBitcoinCore() {
        precondition(UserDefaults.standard.data(forKey: "masterKeyFingerprint") != nil)
        precondition(UserDefaults.standard.array(forKey: "cosigners") != nil)
        activeFileViewControllerManager = FileViewControllerManager(task: .exportBitcoinCore)
        activeFileViewControllerManager!.prompt(vc: self)
    }
    
    func addCosigner() {
        precondition(activeFileViewControllerManager == nil)
        // Prompt user to open JSON file if no wallet exists yet
        precondition(UserDefaults.standard.data(forKey: "cosigners") == nil)
        
        activeFileViewControllerManager = FileViewControllerManager(task: .loadCosigner)
        activeFileViewControllerManager!.prompt(vc: self)
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
