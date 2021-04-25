//
//  WalletListView.swift
//  WalletListView
//
//  Created by Sergey Vinogradov on 21/03/2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct WalletListView: View {
    @ObservedObject var model: WalletListViewModel
    
    @State private var walletToRemove: WalletEntity?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(model.items) { item in
                WalletEntityView(item: item, selected: model.selectedWallet == item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        model.selectedWallet = item
                    }
                    .onLongPressGesture {
                        walletToRemove = item
                    }
            }
        }
        .onAppear() {
            model.viewDidAppear()
        }
        .actionSheet(item: $walletToRemove) { wallet in
            ActionSheet(title: Text("Remove wallet"),
                        message: Text("Do you want to remove \(wallet.label ?? "this wallet")"),
                        buttons: [
                            .destructive(Text("Delete"), action: {
                                model.deleteWallet(wallet)
                            }),
                            .cancel()
                        ])
        }
    }
}

#if DEBUG
struct WalletListView_Previews: PreviewProvider {
    static var previews: some View {
        let view = WalletListView(model: WalletListViewModel(dataManager: DataManager.preview))
        return Group {
            view

            NavigationView {
                view
            }
                .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 350, height: 300))
    }
}
#endif
