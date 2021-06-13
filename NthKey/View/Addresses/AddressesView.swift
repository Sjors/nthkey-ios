//
//  AddressesView.swift
//  AddressesView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AddressesView: View {
    @ObservedObject var model: AddressesViewModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 30.0) {
                if model.items.count > 0 {
                    List {
                        ForEach(model.items) { item in
                            AddressView(item: item)
                        }
                        .onDelete { indexSet in
                            model.markAsUsed(indexSet: indexSet)
                        }
                    }
                } else {
                    Text("Go to Settings to add cosigners")
                }
            }
            .navigationBarTitle("Address")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct AddressessView_Previews: PreviewProvider {
    static var previews: some View {
        let view = AddressesView(model: AddressesViewModel(dataManager: DataManager.preview))

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
