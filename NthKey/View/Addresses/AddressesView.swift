//
//  AddressesView.swift
//  AddressesView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AddressesView: View {
    
    let walletManager: WalletManager
    init(_ walletManager: WalletManager) {
        self.walletManager = walletManager
    }
    
    var body: some View {
        
        NavigationView {
            
            HStack {
                VStack(alignment: .leading, spacing: 10.0) {
                    
                    if (self.walletManager.hasWallet) {
                        List {
                            ForEach(0..<1000) { i in
                                AddressView(multisigAddress(for: i))
                            }
                        }
                        
                    } else {
                        Text("Go to Settings to add cosigners")
                    }
                }
            }
            .navigationBarTitle("Address")
        }
    }
    
    func multisigAddress(for index: Int) -> MultisigAddress {
        // TODO: PRE CREATE ALL OF THEM AND ONLY PASS BACK THE REQUESTED ONE
        MultisigAddress(
            threshold: UInt(self.walletManager.threshold),
            receiveIndex: UInt(index),
            network: self.walletManager.network
        )
    }
}

struct AddressessView_Previews: PreviewProvider {
    static var previews: some View {
        AddressesView(AppState().walletManager)
    }
}
