//
//  SettingsView.swift
//  SettingsView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI
import Combine
import CoreImage.CIFilterBuiltins
import CodeScanner
import LibWally

struct SettingsView : View {

    @EnvironmentObject var appState: AppState

    @State private var showMnemonic = false
    @State private var showPubKeyQR = false
    @State private var isShowingScanner = false
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false

    let settings = SettingsViewController()
    
    // For QR code
    // https://www.hackingwithswift.com/books/ios-swiftui/generating-and-scaling-up-a-qr-code
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func togglePubKeyQR() {
        self.showPubKeyQR = !self.showPubKeyQR
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        switch result {
        case .success(let code):
            DispatchQueue.main.async() {
                self.appState.walletManager.loadWallet(code.data(using: .utf8)!)
            }
        case .failure(let error):
            print("Scanning failed")
            print(error)
        }
    }
    
    func loadWalletFile(_ url: URL) {
        DispatchQueue.main.async() {
            self.appState.walletManager.loadWalletFile(url)
        }
    }

    var body: some View {
        ScrollView {
            HStack{
                VStack(alignment: .leading, spacing: 20.0){
                    if self.appState.walletManager.hasSeed {
                        VStack(alignment: .leading, spacing: 20.0) {
                            Text("Announce").font(.headline)
                            Text("In Specter go to 'Add new device', select Other and scan the QR code.")
                        }
                        Button(action: {
                            self.togglePubKeyQR()
                        }) {
                            Text(self.showPubKeyQR ? "Hide QR" : "Show QR")
                        }
                        if (self.showPubKeyQR) {
                            Image(uiImage: generateQRCode(from: String(data: self.appState.walletManager.ourPubKey(), encoding: .utf8)!))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350, height: 350)
                        }
                        Button(action: {
                            self.settings.exportPublicKey(data: self.appState.walletManager.ourPubKey())
                        }) {
                            Text("Save as JSON")
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 20.0) {
                            Text("Wallet").font(.headline)
                        }
                        if !self.appState.walletManager.hasWallet {
                            Button(action: {
                                self.isShowingScanner = true
                            }) {
                                Text("Scan Specter QR")
                            }
                            Button(action: {
                                self.settings.loadWallet(self.loadWalletFile)
                            }) {
                                Text("Import Specter JSON")
                            }
                        } else {
                            Text("Threshold: \(self.appState.walletManager.threshold)")
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 20.0) {
                            Text("Cosigners").font(.headline)
                            Text("* \( appState.walletManager.us!.fingerprint.hexString )").font(.system(.body, design: .monospaced)) + Text(" (us)")
                            ForEach(appState.walletManager.cosigners) { cosigner in
                                Text("* \( cosigner.fingerprint.hexString )" ).font(.system(.body, design: .monospaced)) + Text(cosigner.name != "" ? " (\(cosigner.name))" : "")
                            }
                            if (self.appState.walletManager.hasWallet) {
                                Button(action: {
                                    self.appState.walletManager.wipeWallet()
                                }) {
                                    Text("Wipe wallet")
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: 20.0) {
                            Text("Misc").font(.headline)
                            Button(action: {
                                self.showMnemonic = true
                            }) {
                                Text("Show mnemonic")
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 20.0) {
                            Text("Your keys").font(.headline)
                            Text("The app generates a fresh cryptographic key for you, or you can recover from a backup by entering its 24 words.")
                        }
                        Button(action: {
                            self.appState.walletManager.generateSeed()
                        }) {
                            Text("Generate fresh keys")
                        }
                        .disabled(self.enterMnemonnic)
                        Button(action: {
                            self.enterMnemonnic = !self.enterMnemonnic
                        }) {
                            Text("Recover from backup")
                        }
                        if self.enterMnemonnic {
                            TextField("battery staple horse...", text: $mnemonicInput)
                                .keyboardType(.alphabet)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .onReceive(Just(mnemonicInput)) { newValue in
                                    // TODO:
                                    // * check every word against BIP39Words
                                    // * suggest autocomplete for each
                                    let words: [String] = newValue.components(separatedBy: " ")
                                    if words.count == 12 || words.count == 16 || words.count == 24 {
                                        // TODO:
                                        // * make BIP39Mnemonic do the above check
                                        // * make isValid public
                                        self.validMnemonic = LibWally.BIP39Mnemonic(words) != nil
                                    } else {
                                        self.validMnemonic = false
                                    }
                                }
                            Button(action: {
                                let words: [String] = self.mnemonicInput.components(separatedBy: " ")
                                self.appState.walletManager.setEntropy(LibWally.BIP39Mnemonic(words)!.entropy)
                            }) {
                                Text("OK").disabled(!self.validMnemonic)
                            }
                        }
                    }
                }
            }
        }.alert(isPresented: $showMnemonic) {
            Alert(title: Text("BIP 39 mnemonic"), message: Text(self.appState.walletManager.mnemonic()), dismissButton: .default(Text("OK")))
        }.sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
        }
    }
}
