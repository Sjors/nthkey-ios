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
        TabView(selection: $appState.selectedTab){
            HStack {
                VStack(alignment: .leading, spacing: 10.0){
                    Text("Addresses")
                        .font(.title)
                    if (self.appState.walletManager.hasWallet) {
                        List {
                            ForEach((0...1000).map {i in MultisigAddress(threshold: UInt(self.appState.walletManager.threshold), receiveIndex: i)}) { address in
                                AddressView(address)
                            }
                        }

                    } else {
                        Text("Go to Settings to add cosigners")
                    }
                }
            }
            .tabItem {
                VStack {
                    Image("first")
                    Text("Addresses")
                }
            }
            .tag(Tab.addresses)
            SignViewController(rootView: SignView()).environmentObject(appState)
            .tabItem {
                VStack {
                    Image("second")
                    Text("Sign")
                }
            }
            .tag(Tab.sign)
            SettingsView()
            .tabItem {
                VStack {
                    Text("Settings")
                }
            }
            .tag(Tab.settings)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

extension ContentView {
    enum Tab: Hashable {
        case addresses
        case sign
        case settings
    }
}
