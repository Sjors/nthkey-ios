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
    @ObservedObject var addressManager = AddressManager() // TODO: use Core Data
    @ObservedObject var defaults = UserDefaultsManager()
    
    let settings = SettingsViewController()
    
    var body: some View {
        TabView(selection: $selection){
            HStack {
                VStack(alignment: .leading, spacing: 10.0){
                    Text("Addresses")
                        .font(.title)
                    if (self.defaults.hasCosigners) {
                        Text(self.addressManager.address).font(.system(.body, design: .monospaced))
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

class AddressManager: ObservableObject {
    @Published var address: String = ""
    private var notificationSubscription: AnyCancellable?

    init() {
        notificationSubscription = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).sink { _ in
            
            if let encodedCosigners = UserDefaults.standard.array(forKey: "cosigners") {
                precondition(!encodedCosigners.isEmpty)
                
                let fingerprint = UserDefaults.standard.data(forKey: "masterKeyFingerprint")!
                
                let entropyItem = KeychainEntropyItem(service: "MultisigService", fingerprint: fingerprint, accessGroup: nil)

                // TODO: handle error
                let entropy = try! entropyItem.readEntropy()
                let mnemonic = BIP39Mnemonic(entropy)!
                let seedHex = mnemonic.seedHex()
                let masterKey = HDKey(seedHex, .testnet)!
                assert(masterKey.fingerprint == fingerprint)
            
                let encodedCosigner = encodedCosigners[0] as! Data
                let cosigner = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encodedCosigner)!
                
                let threshold = UserDefaults.standard.integer(forKey: "threshold")
                precondition(threshold > 0)

                let receiveIndex = 0
                let ourKey = try! masterKey.derive(BIP32Path("m/48h/1'/0'/2'/0/" + String(receiveIndex))!)
                let theirKey = try! cosigner.hdKey.derive(BIP32Path("0/" + String(receiveIndex))!)
                let scriptPubKey = ScriptPubKey(multisig: [ourKey.pubKey, theirKey.pubKey], threshold: 2)
                let receiveAddress = Address(scriptPubKey, .testnet)!
                self.address = receiveAddress.description
            }

            self.objectWillChange.send()
         }
        
    }
    
}


