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

final class SignViewController : UIViewController {
    var activeFileViewControllerManager: DocumentPickerManager?

    var callbackDidGetURL: ((URL) -> Void)?
    var callbackDidSave: (() -> Void)?
    
    func openPSBT(_ callback: @escaping (URL) -> Void ) {
        precondition(activeFileViewControllerManager == nil)
        // TODO: TBC remove because of multiwallet
        // precondition(!UserDefaults.cosigners.isEmpty)
        callbackDidGetURL = callback
        activeFileViewControllerManager = DocumentPickerManager(task: .loadPSBT)
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }
    
    func savePSBT(_ psbt: PSBT, _ callback: @escaping () -> Void) {
        precondition(activeFileViewControllerManager == nil)
        callbackDidSave = callback
        activeFileViewControllerManager = DocumentPickerManager(task: .savePSBT)
        activeFileViewControllerManager!.payload = psbt.data
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }
}

extension SignViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = SignViewController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<SignViewController>)
    -> SignViewController.UIViewControllerType
    {
        return SignViewController()
    }

    func updateUIViewController(
        _ uiViewController: SignViewController.UIViewControllerType,
        context: UIViewControllerRepresentableContext<SignViewController>) {}
}

extension SignViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch activeFileViewControllerManager!.task {
        case .loadPSBT:
            precondition(activeFileViewControllerManager != nil)
            activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
            if let url = activeFileViewControllerManager!.url {
                callbackDidGetURL!(url)
            }
            activeFileViewControllerManager = nil
        case .savePSBT:
            activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
            callbackDidSave!()
            activeFileViewControllerManager = nil
        default:
            precondition(false)
        }
    }
}
