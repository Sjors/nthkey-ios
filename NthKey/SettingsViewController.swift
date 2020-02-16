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
    
    var callbackDidGetURL: ((URL) -> Void)?
    
    override func viewDidLoad() {
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        precondition(activeFileViewControllerManager != nil)
        activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
        if let url = activeFileViewControllerManager!.url {
            callbackDidGetURL!(url)
        }
        activeFileViewControllerManager = nil
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        activeFileViewControllerManager = nil
    }
    
    func exportPublicKey() {
        precondition(activeFileViewControllerManager == nil)
        precondition(UserDefaults.standard.data(forKey: "masterKeyFingerprint") != nil)
        activeFileViewControllerManager = FileViewControllerManager(task: .savePublicKey)
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }
    
    func saveWalletComposer(_ callback: @escaping (URL) -> Void) {
        precondition(activeFileViewControllerManager == nil)
        self.callbackDidGetURL = callback
        activeFileViewControllerManager = FileViewControllerManager(task: .saveWalletComposer)
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }
    
    func exportBitcoinCore() {
        precondition(UserDefaults.standard.data(forKey: "masterKeyFingerprint") != nil)
        precondition(UserDefaults.standard.array(forKey: "cosigners") != nil)
        activeFileViewControllerManager = FileViewControllerManager(task: .exportBitcoinCore)
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }
    
    func addCosigner(_ callback: @escaping (URL) -> Void) {
        precondition(activeFileViewControllerManager == nil)
        
        self.callbackDidGetURL = callback
        activeFileViewControllerManager = FileViewControllerManager(task: .loadCosigner)
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
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
