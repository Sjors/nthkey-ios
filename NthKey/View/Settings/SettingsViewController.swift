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

    var activeFileViewControllerManager: DocumentPickerManager?

    var callbackDidGetURL: ((URL) -> Void)?

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL])
    {
        precondition(activeFileViewControllerManager != nil)
        activeFileViewControllerManager!.didPickDocumentsAt(urls: urls)
        if let url = activeFileViewControllerManager!.url {
            callbackDidGetURL?(url)
        }
        activeFileViewControllerManager = nil
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        activeFileViewControllerManager = nil
    }

    func exportPublicKey(data: Data) {
        precondition(activeFileViewControllerManager == nil)
        precondition(UserDefaults.fingerprints != nil)
        activeFileViewControllerManager = DocumentPickerManager(task: .savePublicKey)
        activeFileViewControllerManager!.payload = data
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }

    func loadWallet(_ callback: @escaping (URL) -> Void) {
        precondition(activeFileViewControllerManager == nil)

        self.callbackDidGetURL = callback
        activeFileViewControllerManager = DocumentPickerManager(task: .loadWallet)
        activeFileViewControllerManager!.prompt(vc: self, delegate: self)
    }

}

extension SettingsViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = SettingsViewController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<SettingsViewController>)
    -> SettingsViewController.UIViewControllerType
    {
        return SettingsViewController()
    }

    func updateUIViewController(
        _ uiViewController: SettingsViewController.UIViewControllerType,
        context: UIViewControllerRepresentableContext<SettingsViewController>)
    {
        // NOTHING HERE
    }

}
