//
//  WalletEntityView.swift
//  WalletEntityView
//
//  Created by Sergey Vinogradov on 21.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import CoreData
import LibWally

struct WalletEntityView: View {
    let item: WalletEntity
    let selected: Bool

    var body: some View {
        HStack {
            Image(systemName: selected ? "checkmark.circle.fill" : "checkmark.circle")
            Text("\(item.label!)")

            Spacer()

            Text(WalletEntityView.networkTitle(network: item.network))
        }
    }
}

extension WalletEntityView {
    static func networkTitle(network: Int16?) -> String {
        guard let net = network else { return "N/A" }
        switch net {
        case Int16(Network.mainnet.rawValue):
            return "Mainnet"
        case Int16(Network.testnet.rawValue):
            return "Testnet"
        default:
            return "N/A"
        }
    }
}

#if DEBUG
struct WalletEntityView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistentStore.preview.container.viewContext
        let request = NSFetchRequest<WalletEntity>(entityName: "WalletEntity")

        return
            Group {
            if let items = try? context.fetch(request),
               let item = items.first {

                let view = List {
                    WalletEntityView(item: item, selected: false)
                    WalletEntityView(item: item, selected: true)
                }
                Group {
                    view

                    view
                        .colorScheme(.dark)
                }
                .previewLayout(.fixed(width: 350, height: 100))
            } else {
                Text("Can't find mock to display")
            }
        }
    }
}
#endif
