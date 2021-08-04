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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20.0) {
                SettingsSectionView("Support") {
                    Link("Tutorial", destination: URL(string:  "https://nthkey.com/tutorial")!)
                    Link("support@nthkey.com", destination: URL(string:  "mailto:support@nthkey.com")!)
                }

                if model.hasSeed {
                    SettingsSectionView("Announce") {
                        AnnounceView(model: model.announceModel,
                                     activeSheet: $model.activeSheet)
                    }

                    SettingsSectionView("Import wallet") {
                        ImportWalletView(model: model.importWalletModel,
                                         activeSheet: $model.activeSheet)
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
                    
                    SettingsSectionView("Legal") {
                        HStack {
                            Link("Privacy Policy", destination: URL(string:  "https://nthkey.com/privacy")!)
                        }
                        HStack {
                            Link("End User License Agreement", destination: URL(string:  "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        }
                        HStack {
                            Link("MIT License and source code", destination: URL(string: "https://github.com/Sjors/nthkey-ios/blob/master/LICENSE.md")!)
                        }
                    }
                } else {
                    NoSeedView(hasSeed: $model.hasSeed)
                }
            }
            .padding(10)
        }
        .sheet(item: $model.activeSheet) { value in
            switch value {
                case .scanner:
                    CodeScannerView(codeTypes: [.qr], completion: model.handleScan)
                case .subscription:
                    SubscriptionView(model: model.subsViewModel,
                                     closeBlock: { model.activeSheet = nil })
            }
        }
        .alert(item: $model.scanQRError) { error in
            Alert(title: Text("Scan wallet QR error"),
                  message: Text(error.errorDescription ?? "Unknown error"),
                  dismissButton: .cancel())
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
