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

final class SignViewController :  UIHostingController<SignView>, ObservableObject, UIViewControllerRepresentable {

    typealias UIViewControllerType = SignViewController
    
    var activeFileViewControllerManager: DocumentPickerManager?

    var coordinator: Coordinator?
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func openPSBT(_ callback: @escaping (URL) -> Void ) {
        precondition(activeFileViewControllerManager == nil)
// FIXME:        precondition(!UserDefaults.cosigners.isEmpty) TBC
        coordinator!.callbackDidGetURL = callback
        activeFileViewControllerManager = DocumentPickerManager(task: .loadPSBT)
        activeFileViewControllerManager!.prompt(vc: self, delegate: coordinator!)
    }
    
    func savePSBT(_ psbt: PSBT, _ callback: @escaping () -> Void) {
        activeFileViewControllerManager = DocumentPickerManager(task: .savePSBT)
        activeFileViewControllerManager!.payload = psbt.data
        activeFileViewControllerManager!.prompt(vc: self, delegate: coordinator!)
        coordinator!.callbackDidSave = callback
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SignViewController>) -> SignViewController.UIViewControllerType {
        self.coordinator = context.coordinator
        self.rootView.vc = self
        return self
    }

    func updateUIViewController(_ uiViewController: SignViewController.UIViewControllerType, context: UIViewControllerRepresentableContext<SignViewController>) {}
    
}

class Coordinator: NSObject, UIDocumentPickerDelegate {
    var callbackDidGetURL: ((URL) -> Void)?
    var callbackDidSave: (() -> Void)?
    var vc: SignViewController

    init(_ vc: SignViewController) {
        self.vc = vc
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch vc.activeFileViewControllerManager!.task {
        case .loadPSBT:
            precondition(vc.activeFileViewControllerManager != nil)
            vc.activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
            if let url = vc.activeFileViewControllerManager!.url {
                callbackDidGetURL!(url)
            }
            vc.activeFileViewControllerManager = nil
        case .savePSBT:
            vc.activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
            callbackDidSave!()
        default:
            precondition(false)
        }
    }

}

