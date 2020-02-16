//
//  FileViewControllerManager.swift
//  FileViewControllerManager
//
//  Created by Sjors Provoost on 13/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import MobileCoreServices
import UIKit
import LibWally

struct FileViewControllerManager {
    enum Task {
        case loadCosigner
        case savePublicKey
        case exportBitcoinCore
        case loadPSBT
        case savePSBT
        case saveWalletComposer
    }
    
    let task: Task
    var payload: Data?
    var url: URL?
    
    func prompt<T: UIViewController>(vc: T, delegate: UIDocumentPickerDelegate) {
        let documentPicker: UIDocumentPickerViewController

        switch task {
        case .loadCosigner:
            let types: [String] = [kUTTypeJSON as String]
            documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        case .loadPSBT:
            documentPicker = UIDocumentPickerViewController(documentTypes: ["org.bitcoin.psbt"], in: .import)
        case .savePublicKey, .exportBitcoinCore, .savePSBT, .saveWalletComposer:
            documentPicker =
            UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        }
        documentPicker.delegate = delegate
        documentPicker.modalPresentationStyle = .formSheet
        
        DispatchQueue.main.async {
            self.getTopMostViewController()!.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    mutating func didPickDocumentsAt(urls: [URL]) -> Void {
        switch task {
        case .loadCosigner:
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
        case .exportBitcoinCore:
            if (urls.count != 1) {
                NSLog("Please select 1 directory")
            }
            precondition(urls[0].hasDirectoryPath)
            exportBitcoinCore(urls[0])
        case .savePSBT:
            if (urls.count != 1) {
                NSLog("Please select 1 directory")
            }
            precondition(urls[0].hasDirectoryPath)
            savePSBT(urls[0])
        case .saveWalletComposer:
            if (urls.count != 1) {
                NSLog("Please select 1 directory")
            }
            self.url = urls[0]
        }
    }

    func exportBitcoinCore(_ url: URL) {
        let (us, cosigners) = Signer.getSigners()

        let threshold = UserDefaults.standard.integer(forKey: "threshold")
        precondition(threshold > 0)

        let importData = BitcoinCoreImport([us] + cosigners, threshold: UInt(threshold))

        let fileName = "bitcoin-core-importdescriptors-" + us.fingerprint.hexString + ".txt";
        let textData = importData!.importDescriptorsRPC.data(using: .utf8)!
        writeFile(folderUrl: url, fileName: fileName, textData: textData)
    }
    
    func savePSBT(_ url: URL) {
        precondition(self.payload != nil)

        let fileName = "transaction-signed.psbt"; // TODO: use txid, and also save hex if complete
        writeFile(folderUrl: url, fileName: fileName, textData: self.payload!)
    }
      
    func savePublicKeyFile(_ url: URL) {
        precondition(UserDefaults.standard.data(forKey: "masterKeyFingerprint") != nil)
        let fingerprint = UserDefaults.standard.data(forKey: "masterKeyFingerprint")!
        let entropyItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: fingerprint, accessGroup: nil)

        // TODO: handle error
        let entropy = try! entropyItem.readEntropy()
        let mnemonic = BIP39Mnemonic(entropy)!
        let seedHex = mnemonic.seedHex()
        let masterKey = HDKey(seedHex, .testnet)!
        assert(masterKey.fingerprint == fingerprint)
              
        let path = BIP32Path("m/48h/1h/0h/2h")!
        let account = try! masterKey.derive(path)

        // Coldcard compatible JSON format:
        struct ColdcardExport : Codable {
            var xfp: String
            var p2wsh_deriv: String
            var p2wsh: String
        }
        // TODO: get Vpub or Data directly from LibWally
        let xpub = Data(base58: account.xpub)!
        // Convert tpub to Electrum compatible Vpub:
        let p2wsh_tpub = Data("02575483")! + xpub.subdata(in: 4..<xpub.count)
        let export = ColdcardExport(xfp: fingerprint.hexString.uppercased(), p2wsh_deriv: "m/48'/1'/0'/2'", p2wsh: p2wsh_tpub.base58)

        let encoder = JSONEncoder()
        let data = try! encoder.encode(export)

        let fileName = "ccxp-" + fingerprint.hexString.uppercased() + ".json";
        writeFile(folderUrl: url, fileName: fileName, textData: data)
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
