//
//  ContentView.swift
//  Multisig
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    let settings = SettingsViewController()
 
    var body: some View {
        TabView(selection: $selection){
            Text("Addresses")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("first")
                        Text("Addresses")
                    }
                }
                .tag(0)
            Text("Settings")
                .font(.title)
                .tabItem {
                    settings
                }.onAppear {
                    self.settings.viewDidAppear(false)
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
