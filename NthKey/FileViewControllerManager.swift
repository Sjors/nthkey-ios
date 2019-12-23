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
        case .savePublicKey, .exportBitcoinCore, .savePSBT:
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
            loadCosignerFile(urls[0])
        case .loadPSBT:
            if (urls.count != 1) {
                NSLog("Please select 1 PSBT file")
            }
            self.url = urls[0]
        case .savePublicKey:
            print(urls[0])
            if (urls.count != 1) {
                NSLog("Please select 1 directory")
            }
            precondition(urls[0].hasDirectoryPath)
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
            
      }
    }
        
    func loadCosignerFile(_ url: URL) {
          do {
              let data = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
              let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
              if let jsonResult = jsonResult as? Dictionary<String, String>,
                  let xfp = jsonResult["xfp"],
                  let p2wsh_deriv = jsonResult["p2wsh_deriv"],
                  let p2wsh = jsonResult["p2wsh"]
              {
                  let vpub = Data(base58: p2wsh)!
                  let vpubMarker = Data("02575483")! // Vpub (testnet, p2wsh, public)
                  if (vpub.subdata(in: 0..<4) != vpubMarker) {
                      NSLog("Expected Vpub marker 0x%@, got 0x%@", vpubMarker.hexString, vpub.subdata(in: 0..<4).hexString)
                      return
                  }
                  let p2wsh_tpub = Data("043587cf")! + vpub.subdata(in: 4..<vpub.count)
                  let cosigner = Signer(fingerprint: Data(xfp)!, derivation: BIP32Path(p2wsh_deriv)!, hdKey: HDKey(p2wsh_tpub.base58)!)
                  let encoded = try! NSKeyedArchiver.archivedData(withRootObject: cosigner, requiringSecureCoding: true)
                  let defaults = UserDefaults.standard
                  defaults.set([encoded], forKey: "cosigners")
                  defaults.set(2, forKey: "threshold")
                  NSLog("Cosigner %@ added" , xfp)
              }
          } catch {
              NSLog("Something went wrong parsing JSON file")
              return
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
        let export = ColdcardExport(xfp: fingerprint.hexString.uppercased(), p2wsh_deriv: "m/48'/1'/0'/2'", p2wsh: account.xpub)

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
