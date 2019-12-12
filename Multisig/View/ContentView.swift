//
//  ContentView.swift
//  Multisig
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import SwiftUI
import Combine
import LibWally

struct ContentView: View {
    @State private var selection = 0
    @ObservedObject var defaults = UserDefaultsManager()
    
    let settings = SettingsViewController()
    
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
            HStack{
                VStack(alignment: .leading, spacing: 20.0){
                    Button(action: {
                        self.settings.exportPublicKey()
                    }) {
                        Text("Export public key")
                    }
                    Button(action: {
                        self.settings.addCosigner()
                    }) {
                        Text("Add cosigner")
                    }
                    .disabled(self.defaults.hasCosigners)
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "cosigners")
                    }) {
                        Text("Wipe cosigners")
                    }
                    .disabled(!self.defaults.hasCosigners)
                }
            }
            .tabItem {
                VStack {
                    Image("second")
                    Text("Settings")
                }
                settings // TODO: avoid sticking UIViewController in a tab item
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

class UserDefaultsManager: ObservableObject {
    @Published var hasCosigners: Bool = UserDefaults.standard.array(forKey: "cosigners") != nil
    private var notificationSubscription: AnyCancellable?

    init() {
        notificationSubscription = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).sink { _ in
            self.hasCosigners = UserDefaults.standard.array(forKey: "cosigners") != nil
            self.objectWillChange.send()
         }
        
    }
    
}
