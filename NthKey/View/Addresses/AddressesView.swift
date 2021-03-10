//
//  AddressesView.swift
//  AddressesView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import CoreData

struct AddressesView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \AddressEntity.receiveIndex, ascending: true)])
    private var items: FetchedResults<AddressEntity>

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 30.0) {
                if items.count > 0 {
                    List {
                        ForEach(items) { item in
                            AddressView(item: item)
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
        let context = PersistentStore.preview.container.viewContext
        let view = AddressesView()
            .environment(\.managedObjectContext, context)

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
