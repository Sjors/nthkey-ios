//
//  AddressesView.swift
//  AddressesView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AddressesView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 10.0) {
                
                if (self.appState.walletManager.hasWallet) {
                    List {
                        ForEach(0..<1000) { i in
                            AddressView(multisigAddress(for: i))
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
    
    private func multisigAddress(for index: Int) -> MultisigAddress {
        // TODO: PRE CREATE ALL OF THEM AND ONLY PASS BACK THE REQUESTED ONE
        MultisigAddress(
            threshold: UInt(self.appState.walletManager.threshold),
            receiveIndex: UInt(index),
            network: self.appState.walletManager.network
        )
    }
}

#if DEBUG
struct AddressessView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        // FIXME: prepare mockups to preview all cases - appState.walletManager.hasWallet = true
        let view = AddressesView()
            .environmentObject(appState)
        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }

    }
}
#endif
