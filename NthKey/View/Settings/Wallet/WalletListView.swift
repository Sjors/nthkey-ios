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

    @Binding var isShowingScanner: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(model.items) { item in
                WalletEntityView(item: item, selected: model.selectedWallet == item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        model.selectedWallet = item
                    }
            }
            Button(action: {
                isShowingScanner = true
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add a wallet by scan QR")
                }
                .foregroundColor(.accentColor)
            }
            Button(action: {
                model.addWalletByFile()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add a wallet by import JSON")
                }
                .foregroundColor(.accentColor)
            }
            // TODO: Think about UX to remove a wallet
        }
        .onAppear() {
            model.viewDidAppear()
        }
    }
}

#if DEBUG
struct WalletListView_Previews: PreviewProvider {
    static var previews: some View {
        let view = WalletListView(model: WalletListViewModel(dataManager: DataManager.preview), isShowingScanner: .constant(false))
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
