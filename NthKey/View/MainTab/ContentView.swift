//
//  ContentView.swift
//  Nth Key
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: ContentViewModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            AddressesView(model: model.addressesModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Addresses")
                }
                .tag(ContentViewTab.addresses)
            
            SignView(model: model.signViewModel)
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text("Sign")
                }
                .tag(ContentViewTab.sign)
            
            SettingsView(model: model.settingsModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(ContentViewTab.settings)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ContentViewModel(dataManager: DataManager.preview)
        model.selectedTab = ContentViewTab.addresses

        let view = ContentView(model: model)

        return Group {
            view

            view
                .colorScheme(.dark)
        }
    }
}
#endif
