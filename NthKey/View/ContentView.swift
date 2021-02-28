//
//  ContentView.swift
//  Nth Key
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import SwiftUI
import LibWally

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            AddressesView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Addresses")
                }
                .tag(Tab.addresses)
            
            SignViewController(rootView: SignView())
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text("Sign")
                }
                .tag(Tab.sign)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(Tab.settings)
        }
    }
}

extension ContentView {
    enum Tab: Hashable {
        case addresses
        case sign
        case settings
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        var appState: AppState {
            let result = AppState()
            result.selectedTab = .addresses
            return result
        }

        let view = ContentView()
            .environmentObject(appState)

        return Group {
            view

            view
                .colorScheme(.dark)
        }
    }
}
#endif
