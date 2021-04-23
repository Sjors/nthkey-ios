//
//  WalletEntityView.swift
//  WalletEntityView
//
//  Created by Sergey Vinogradov on 21.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import LibWally

struct WalletEntityView: View {
    let item: WalletEntity
    let selected: Bool

    var body: some View {
        HStack {
            Image(systemName: selected ? "checkmark.circle.fill" : "checkmark.circle")
            Text("\(item.label ?? "N/A")")

            Spacer()

            Text(WalletEntityView.networkTitle(network: item.network))
        }
    }
}

extension WalletEntityView {
    static func networkTitle(network: Int16?) -> String {
        guard let net = network,
              let value: WalletNetwork = WalletNetwork.valueFromInt16(net) else {
            return "N/A"
        }
        return value.title
    }
}

#if DEBUG
import CoreData

struct WalletEntityView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistentStore.preview.container.viewContext
        let request = NSFetchRequest<WalletEntity>(entityName: "WalletEntity")

        return Group {
            if let items = try? context.fetch(request) {
                let view = List {
                    ForEach(items) { item in
                        WalletEntityView(item: item, selected: Bool.random())
                    }
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
