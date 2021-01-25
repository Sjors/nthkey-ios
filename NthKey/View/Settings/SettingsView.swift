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
import CodeScanner
import LibWally

struct SettingsView : View {

    @EnvironmentObject var appState: AppState

    @State private var showMnemonic = false
    @State private var isShowingScanner = false
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false
    @State private var promptMainnet = false

    let settings = SettingsViewController()
    
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

    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 20.0) {
                    if self.appState.walletManager.hasSeed {
                        
                        AnnounceView(manager: self.appState.walletManager, settings: settings)
                        
                        Spacer()
                        
                        WalletView(isShowingScanner: self.isShowingScanner, settings: settings)
                        
                        Spacer()
                        
                        CodeSignersView()
                            .environmentObject(self.appState)
                        
                        VStack(alignment: .leading, spacing: 20.0) {
                            Text("Misc").font(.headline)
                            Button(action: {
                                self.showMnemonic = true
                            }) {
                                Text("Show mnemonic")
                            }.alert(isPresented: $showMnemonic) {
                                Alert(title: Text("BIP 39 mnemonic"), message: Text(self.appState.walletManager.mnemonic()), dismissButton: .default(Text("OK")))
                            }
                            if self.appState.walletManager.network == .testnet {
                                Text("Feeling reckless?")
                                if (self.appState.walletManager.hasWallet) {
                                    Text("You need to wipe your existing testnet wallet first")
                                }
                                Button(action: {
                                    self.promptMainnet = true
                                }) {
                                    Text("Switch to mainnet")
                                }
                                .disabled(self.appState.walletManager.hasWallet)
                                .alert(isPresented:$promptMainnet) {
                                    Alert(title: Text("Switch to mainnet?"),
                                          message: Text("This app is still very new. Use only coins that you're willing to loose and write down your mnemonic. Switching back to testnet requires deleting and reinstalling the app."),
                                          primaryButton: .destructive(Text("Confirm")) {
                                            self.appState.walletManager.setMainnet()
                                    }, secondaryButton: .cancel())
                                }
                            }
                        }
                    } else {
                        NoSeedView()
                            .environmentObject(self.appState)
                    }
                }
                .padding(10)
            }
        }.sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
        }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
    }
}
