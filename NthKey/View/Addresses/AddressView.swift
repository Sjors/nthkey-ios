//
//  AddressView.swift
//  AddressView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AddressView: View {
    let item: AddressProxy

    var body: some View {
        HStack {
            Image(systemName: item.used ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title)
                .foregroundColor(.primary)

            Text(item.address)
                .strikethrough(item.used)
        }
    }
}

#if DEBUG
import CoreData

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistentStore.preview.container.viewContext
        let request = NSFetchRequest<AddressEntity>(entityName: "AddressEntity")

        return Group {
            if let items = try? context.fetch(request),
               let addressUsed = items.first{ $0.used }?.address,
               let addressNotUsed = items.first{ !$0.used }?.address {

                ForEach(ColorScheme.allCases, id: \.self) { scheme in
                    List {
                        AddressView(item: AddressProxy(address: addressUsed, used: true))
                        AddressView(item: AddressProxy(address: addressNotUsed, used: false))
                    }
                    .frame(idealHeight: 100, maxHeight: 150)
                    .colorScheme(scheme)
                }
                .previewLayout(.sizeThatFits)
            } else {

                Text("Can't find mock to display")
            }
        }
    }
}
#endif
