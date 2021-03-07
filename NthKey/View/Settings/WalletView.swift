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
    @Binding var isShowingScanner: Bool
    // TODO: Incapsulate it in view model or on upper level
    var settings: SettingsViewController

    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Wallet").font(.headline)

            if self.appState.walletManager.hasWallet {
                Text("Threshold: \(self.appState.walletManager.threshold)")
            } else {
                Button("Scan Specter QR") {
                    self.isShowingScanner = true
                }
                Button("Import Specter JSON") {
                    self.settings.loadWallet(self.loadWalletFile)
                }
            }
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
            WalletView(isShowingScanner: .constant(false), settings: settingsController)
                .environmentObject(AppState())

            NavigationView {
                WalletView(isShowingScanner: .constant(false), settings: settingsController)
                    .environmentObject(appState)
            }
            .colorScheme(.dark)
        }
    }
}
#endif
