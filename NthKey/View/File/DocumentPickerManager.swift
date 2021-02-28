//
//  DocumentPickerManager.swift
//  DocumentPickerManager
//
//  Created by Sjors Provoost on 13/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import MobileCoreServices
import UIKit
import LibWally

struct DocumentPickerManager {
    
    enum Task {
        case loadWallet
        case savePublicKey
        case loadPSBT
        case savePSBT
    }

    let task: Task
    var payload: Data?
    var url: URL?

    func prompt<T: UIViewController>(vc: T, delegate: UIDocumentPickerDelegate) {
        let documentPicker: UIDocumentPickerViewController

        switch task {
        case .loadWallet:
            let types: [String] = [kUTTypeJSON as String]
            documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            
        case .loadPSBT:
            documentPicker = UIDocumentPickerViewController(documentTypes: ["org.bitcoin.psbt"], in: .import)
            
        case .savePublicKey,
             .savePSBT:
            
            documentPicker =
            UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        }
        documentPicker.delegate = delegate
        documentPicker.modalPresentationStyle = .formSheet

        guard let topController = getTopMostViewController() else { return }
        DispatchQueue.main.async {
            topController.present(documentPicker, animated: true, completion: nil)
        }
    }

    mutating func didPickDocumentsAt(urls: [URL]) -> Void {
        switch task {
        case .loadWallet:
            if (urls.count != 1) {
                NSLog("Please select 1 JSON file")
            }
            self.url = urls[0]
        case .loadPSBT:
            if (urls.count != 1) {
                NSLog("Please select 1 PSBT file")
            }
            self.url = urls[0]
        case .savePublicKey:
            if (urls.count != 1) {
                NSLog("Please select 1 directory")
            }
            precondition(urls[0].hasDirectoryPath)
            #if targetEnvironment(simulator)
            print(urls[0])
            #endif
            savePublicKeyFile(urls[0])
        case .savePSBT:
            if (urls.count != 1) {
                NSLog("Please select 1 directory")
            }
            precondition(urls[0].hasDirectoryPath)
            savePSBT(urls[0])
        }
    }

    func savePSBT(_ url: URL) {
        guard let payload = payload else { return }

        let fileName = "transaction-signed.psbt"; // TODO: use txid, and also save hex if complete
        writeFile(folderUrl: url, fileName: fileName, textData: payload)
    }

    func savePublicKeyFile(_ url: URL) {
        guard
            let payload = payload,
            let fingerprint = UserDefaults.fingerprint
        else { return }
        
        let fileName = "ccxp-" + fingerprint.hexString.uppercased() + ".json";
        writeFile(folderUrl: url, fileName: fileName, textData: payload)
    }

    func writeFile(folderUrl: URL, fileName: String, textData: Data) {
        guard folderUrl.startAccessingSecurityScopedResource() else {
            print("Access failure")
            return
        }
        defer { folderUrl.stopAccessingSecurityScopedResource() }

        let fileURL = NSURL.fileURL(withPath: fileName, relativeTo: folderUrl)

        do {
            try textData.write(to: fileURL)
        } catch {
            print("Failed to write")
        }

    }

    // FIXME: WHAT ABOUT NAVIGATIONS & TAB CONTROLLERS?
    // TODO: MOVE IT TO GLOBAL APP LEVEL HELPERS
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

}
