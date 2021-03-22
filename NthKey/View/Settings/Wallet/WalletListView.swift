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

    var body: some View {
        List {
            ForEach(model.items) { item in
                WalletEntityView(item: item, selected: model.selectedWallet == item)
                .onTapGesture {
                    model.selectedWallet = item
                }
            }
            Button(action: {
                model.addWallet()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add a wallet")
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}

#if DEBUG
struct WalletListView_Previews: PreviewProvider {
    static var previews: some View {
        let view = WalletListView(model: WalletListViewModel.mock)
        return Group {
            view

            view
                .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 350, height: 200))
    }
}
#endif
