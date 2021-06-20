//
//  AddressView.swift
//  AddressView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AddressView: View {
    let item: AddressEntity
    let markAction: () -> Void

    private var address: String {
        item.address ?? "N/A"
    }

    var body: some View {
        HStack {
            Button(action: markAction, label: {
                Image(systemName: item.used ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.primary)
            })
            .contentShape(Rectangle())

            Text(address)
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
               let itemUsed = items.first{ $0.used } ,
               let itemNotUsed = items.first{ !$0.used } {
                let viewUsed =  AddressView(item: itemUsed) {}
                let viewNotUsed = AddressView(item: itemNotUsed) {}
                let view = VStack(spacing: 30) {
                    viewUsed
                    viewNotUsed
                }

                Group {
                    view

                    NavigationView { view }
                        .colorScheme(.dark)
                        .previewLayout(.fixed(width: 350, height: 200))
                }
                .previewLayout(.sizeThatFits)
            } else {

                Text("Can't find mock to display")
            }
        }
    }
}
#endif
