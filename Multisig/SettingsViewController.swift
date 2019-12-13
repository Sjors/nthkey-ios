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
        
        let encodedCosigners = UserDefaults.standard.array(forKey: "cosigners")!
        precondition(!encodedCosigners.isEmpty)
        
        let fingerprint = UserDefaults.standard.data(forKey: "masterKeyFingerprint")!
        let entropyItem = KeychainEntropyItem(service: "MultisigService", fingerprint: fingerprint, accessGroup: nil)

        // TODO: deduplicate from MultisigAddress.swift
        let entropy = try! entropyItem.readEntropy()
        let mnemonic = BIP39Mnemonic(entropy)!
        let seedHex = mnemonic.seedHex()
        let masterKey = HDKey(seedHex, .testnet)!
        assert(masterKey.fingerprint == fingerprint)
        
        let path = BIP32Path("m/48h/1h/0h/2h")!
        let ourKey = try! masterKey.derive(path)
        let us = Signer(fingerprint: fingerprint, derivation: path, hdKey: ourKey)
    
        let encodedCosigner = encodedCosigners[0] as! Data
        let cosigner = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encodedCosigner)!
        
        let threshold = UserDefaults.standard.integer(forKey: "threshold")
        precondition(threshold > 0)
        
        let importData = BitcoinCoreImport([us, cosigner], threshold: UInt(threshold))
        print(importData!.importDescriptorsRPC)

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
