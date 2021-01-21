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
        TabView {
            
            AddressessView(appState.walletManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Addresses")
                }
            
            SignViewController(rootView: SignView())
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text("Sign")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

extension ContentView {
    enum Tab {
        case addresses
        case sign
        case settings
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
