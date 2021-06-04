//
//  ImportWalletView.swift
//  ImportWalletView
//
//  Created by Sergey Vinogradov on 25.04.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct ImportWalletView: View {
    @ObservedObject var model: ImportWalletViewModel

    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        let binding = Binding<WalletNetwork>(get: { model.selectedNetwork }) { network in
            guard network == .mainnet && !model.hasSubscription else {
                model.selectedNetwork = network
                return
            }

            model.selectMainnetAfterPurchase = true
            activeSheet = .subscription
        }

        return VStack(alignment: .leading, spacing: 20) {
            NetworkPickerView(network: binding)
            
            Button(action: {
                activeSheet = .scanner
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Scan wallet QR code")
                }
                .foregroundColor(.accentColor)
            }
            Button(action: {
                model.addWalletByFile()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Import wallet JSON")
                }
                .foregroundColor(.accentColor)
            }
        }
        .alert(item: $model.loadWalletError) { error in
            Alert(title: Text("Load wallet error"),
                  message: Text(error.errorDescription ?? "Unknown error"),
                  dismissButton: .cancel())
        }
    }
}

#if DEBUG
struct ImportWalletView_Previews: PreviewProvider {
    static var previews: some View {
        ImportWalletView(model: ImportWalletViewModel(dataManager: DataManager.preview,
                                                      subsManager: SubscriptionManager.mock),
                         activeSheet: .constant(.scanner))
    }
}
#endif
