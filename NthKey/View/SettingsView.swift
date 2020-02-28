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

struct SettingsView : View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var showMnemonic = false
    @State private var threshold = "2"

    let settings = SettingsViewController()
    
    func loadCosignerFile(_ url: URL) {
        DispatchQueue.main.async() {
            self.appState.walletManager.loadCosignerFile(url)
        }
    }
    
    func saveWalletComposer(_ url: URL) {
        DispatchQueue.main.async() {
            self.appState.walletManager.saveWalletComposer(url)
        }
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 20.0){
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Cosigners").font(.headline)
                    if !self.appState.walletManager.hasWallet {
                        Text("Add cosigners by importing their public key here.")
                    }
                    Text("* \( appState.walletManager.us.fingerprint.hexString )").font(.system(.body, design: .monospaced)) + Text(" (us)")
                    ForEach(appState.walletManager.cosigners) { cosigner in
                        Text("* \( cosigner.fingerprint.hexString )" ).font(.system(.body, design: .monospaced)) + Text(cosigner.name != "" ? " (\(cosigner.name))" : "")
                    }
                    if !self.appState.walletManager.hasWallet {
                        Button(action: {
                            self.settings.addCosigner(self.loadCosignerFile)
                        }) {
                            Text("Add cosigner")
                        }
                        HStack{
                            Text("Threshold:")
                            TextField("Threshold", text: $threshold)
                            .keyboardType(.numberPad)
                            .onReceive(Just(threshold)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.threshold = filtered
                                }
                            }
                        }
                        Button(action: {
                              self.appState.walletManager.createWallet(threshold: Int(self.threshold) ?? 0)
                          }) {
                              Text("Create \(threshold) of \(max(2, self.appState.walletManager.cosigners.count + 1)) wallet")
                          }
                          .disabled(Int(self.threshold) ?? 0 <= 1 || Int(self.threshold)! > self.appState.walletManager.cosigners.count + 1)
                    } else {
                        Text("Threshold: \(self.appState.walletManager.threshold)")
                    }

                    if !self.appState.walletManager.hasWallet && self.appState.walletManager.hasCosigners {
                        Button(action: {
                            self.appState.walletManager.wipeCosigners()
                        }) {
                            Text("Wipe cosigners")
                        }
                    }
                    if (self.appState.walletManager.hasWallet) {
                        Button(action: {
                            self.appState.walletManager.wipeWallet()
                        }) {
                            Text("Wipe wallet")
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Announce").font(.headline)
                    Text("Announce your key to your cosigners and import the wallet into Bitcoin Core")
                }
                Button(action: {
                    self.settings.exportPublicKey()
                }) {
                    Text("ColdCard format")
                }
                Button(action: {
                    self.settings.saveWalletComposer(self.saveWalletComposer)
                }) {
                    Text("Experimental format")
                }
                Button(action: {
                    self.settings.exportBitcoinCore()
                }) {
                    Text("Bitcoin Core import script")
                }
                .disabled(!self.appState.walletManager.hasWallet)
                Spacer()
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Misc").font(.headline)
                    Button(action: {
                        self.showMnemonic = true
                    }) {
                        Text("Show mnemonic")
                    }
                }

                Spacer()
            }
        }.alert(isPresented: $showMnemonic) {
            Alert(title: Text("BIP 39 mnemonic"), message: Text(self.appState.walletManager.mnemonic()), dismissButton: .default(Text("OK")))
        }
    }
}
