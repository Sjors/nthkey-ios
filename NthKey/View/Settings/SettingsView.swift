//
//  SettingsView.swift
//  SettingsView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import CodeScanner

struct SettingsView : View {
    @ObservedObject var model: SettingsViewModel

    @EnvironmentObject var appState: AppState

    @State private var showMnemonic = false
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false
    @State private var promptMainnet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20.0) {
                if self.appState.walletManager.hasSeed {
                    SettingsSectionView("Announce") {
                        AnnounceView(model: AnnounceViewModel(manager: appState.walletManager))
                    }

                    SettingsSectionView("Import wallet") {
                        ImportWalletView(model: model.importWalletModel,
                                         isShowingScanner: $model.isShowingScanner)
                    }

                    SettingsSectionView("Wallets") {
                        WalletListView(model: model.walletListModel)
                    }

                    SettingsSectionView("Wallet details") {
                        CodeSignersView(model: model.codeSignersModel)
                    }

                    SettingsSectionView("Misc") {
                        MiscSettings()
                            .environmentObject(self.appState)
                    }
                } else {
                    NoSeedView()
                        .environmentObject(self.appState)
                }
            }
            .padding(10)
            
        }.sheet(isPresented: $model.isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: model.handleScan)
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let seededAppState = AppState()
        seededAppState.walletManager.hasSeed = true

        let view = SettingsView(model: SettingsViewModel.mock)

        return Group {
            view

                .environmentObject(seededAppState)

            NavigationView {
                view
                    .environmentObject(AppState())
            }
            .colorScheme(.dark)
        }
    }
}
#endif
