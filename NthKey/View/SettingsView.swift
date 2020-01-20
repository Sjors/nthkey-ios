//
//  SettingsView.swift
//  SettingsView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI

struct SettingsView : View {
    
    @EnvironmentObject var appState: AppState

    let settings = SettingsViewController()
    
    func loadCosignerFile(_ url: URL) {
        DispatchQueue.main.async() {
            self.appState.walletManager.loadCosignerFile(url)
        }
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 20.0){
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Step 1").font(.headline)
                    Text("Add cosigners by importing their public key here.")
                    Text("* \( appState.walletManager.us.fingerprint.hexString )").font(.system(.body, design: .monospaced)) + Text(" (us)")
                    ForEach(appState.walletManager.cosigners) { cosigner in
                        Text("* \( cosigner.fingerprint.hexString )").font(.system(.body, design: .monospaced))
                    }
                    Button(action: {
                        self.settings.addCosigner(self.loadCosignerFile)
                    }) {
                        Text("Add cosigner")
                    }
                    .disabled(self.appState.walletManager.hasWallet)
                    Button(action: {
                        self.appState.walletManager.createWallet()
                    }) {
                        Text("Create wallet")
                    }
                    .disabled(self.appState.walletManager.hasWallet || !self.appState.walletManager.hasCosigners)
                    Button(action: {
                        self.appState.walletManager.wipeCosigners()
                    }) {
                        Text("Wipe cosigners")
                    }
                    .disabled(!self.appState.walletManager.hasCosigners)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Step 2").font(.headline)
                    Text("Announce your key to your cosigners.")
                }
                Button(action: {
                    self.settings.exportPublicKey()
                }) {
                    Text("Export public key")
                }
                Spacer()
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Step 3").font(.headline)
                    Text("Use this wallet Bitcoin Core.")
                }
                Button(action: {
                    self.settings.exportBitcoinCore()
                }) {
                    Text("Bitcoin Core import script")
                }
                .disabled(!self.appState.walletManager.hasCosigners)
                Spacer()
            }
        }
    }
}
