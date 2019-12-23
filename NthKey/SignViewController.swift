//
//  SignViewController.swift
//  SignViewController
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import UIKit
import LibWally

final class SignViewController : UIViewController, UIDocumentPickerDelegate, ObservableObject {
    
    var activeFileViewControllerManager: FileViewControllerManager?
    @Published var psbt: PSBT?
    @Published var destinations: [Destination]?
    @Published var signed: Bool = false
    @Published var canSign: Bool = false
    
    override func viewDidLoad() {
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch self.activeFileViewControllerManager!.task {
        case .loadPSBT:
            let (masterKey, _, _) = Signer.getSigners()
            do {
                precondition(activeFileViewControllerManager != nil)
                activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
                if let payload = activeFileViewControllerManager!.payload {
                    self.psbt = try PSBT(payload, .testnet)
                    self.destinations = self.psbt!.outputs.map { output in
                        return Destination(output: output, inputs: self.psbt!.inputs)
                    }
                }
                activeFileViewControllerManager = nil
                self.canSign = false
                for input in self.psbt!.inputs {
                    // TODO: use account level hdKey instead of masterkey, and use only public key
                    self.canSign = self.canSign || input.canSign(masterKey) as Bool
                }
            } catch {
                NSLog("Something went wrong parsing JSON file")
                return
            }
        case .savePSBT:
            self.signed = true
            activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
        default:
            precondition(false)
        }
        

    }
    
    func loadPSBT() {
        precondition(activeFileViewControllerManager == nil)
        precondition(UserDefaults.standard.array(forKey: "cosigners") != nil)
        
        activeFileViewControllerManager = FileViewControllerManager(task: .loadPSBT)
        activeFileViewControllerManager!.prompt(vc: self)
        self.signed = false
    }
    
    func signPSBT() {
        let signedPsbt = Signer.signPSBT(self.psbt!)
        activeFileViewControllerManager = FileViewControllerManager(task: .savePSBT)
        activeFileViewControllerManager!.payload = signedPsbt.data
        activeFileViewControllerManager!.prompt(vc: self)
        // We've signed, but there's no seperate save button yet
        // self.signed = true
    }
    
    func clearPSBT() {
        self.psbt = nil
        self.signed = false
    }

}

extension SignViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = SignViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SignViewController>) -> SignViewController.UIViewControllerType {
        return SignViewController()
    }

    func updateUIViewController(_ uiViewController: SignViewController.UIViewControllerType, context: UIViewControllerRepresentableContext<SignViewController>) {
    }
    
}
