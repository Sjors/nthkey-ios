//
//  ContentView.swift
//  Multisig
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import SwiftUI
import LibWally

struct ContentView: View {
    @State private var selection = 0
    @ObservedObject var defaults = UserDefaultsManager()
        
    var body: some View {
        TabView(selection: $selection){
            HStack {
                VStack(alignment: .leading, spacing: 10.0){
                    Text("Addresses")
                        .font(.title)
                    if (self.defaults.hasCosigners) {
                        List {
                            ForEach((0...1000).map {i in MultisigAddress(i)}) { address in
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
            .tag(0)
            SettingsView()
            .tabItem {
                VStack {
                    Image("second")
                    Text("Settings")
                }
            }
            .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
