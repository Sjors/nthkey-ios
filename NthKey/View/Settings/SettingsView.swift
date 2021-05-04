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

    @State private var showMnemonic = false
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false
    @State private var promptMainnet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20.0) {
                if let url = URL(string:  "https://nthkey.com/tutorial") {
                    SettingsSectionView("Tutorial") {
                        HStack {
                            if #available(iOS 14.0, *) {
                                Link("Open tutorial", destination: url)
                            } else {
                                Button("Open tutorial") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                }

                if model.hasSeed {
                    SettingsSectionView("Announce") {
                        AnnounceView(model: AnnounceViewModel())
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
                    }
                } else {
                    NoSeedView(hasSeed: $model.hasSeed)
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
        Group {
            SettingsView(model: SettingsViewModel.mock)

            NavigationView {
                SettingsView(model: SettingsViewModel.notSeeded)
            }
            .colorScheme(.dark)
        }
    }
}
#endif
