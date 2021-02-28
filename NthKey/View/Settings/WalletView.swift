//
//  WalletView.swift
//  WalletView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct WalletView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var isShowingScanner = false
    
    private let settings: SettingsViewController
    init(isShowingScanner: Bool, settings: SettingsViewController) {
        self.settings = settings
        self.isShowingScanner = isShowingScanner
    }

    var body: some View {
        
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
        
    }
    
    func loadWalletFile(_ url: URL) {
        DispatchQueue.main.async() {
            self.appState.walletManager.loadWalletFile(url)
        }
    }
    
}

#if DEBUG
struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        appState.walletManager.hasWallet = true

        let settingsController = SettingsViewController()

        return Group {
            WalletView(isShowingScanner: true, settings: settingsController)
                .environmentObject(AppState())

            NavigationView {
                WalletView(isShowingScanner: true, settings: settingsController)
                    .environmentObject(appState)
            }
            .colorScheme(.dark)
        }
    }
}
#endif
