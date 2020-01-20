//
//  SignView.swift
//  SignView
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI
import LibWally

struct SignView : View {
    @EnvironmentObject var appState: AppState
    
    var vc: SignViewController? = nil
    
    func openPSBT(_ url: URL) {
        DispatchQueue.main.async() {
            self.appState.psbtManager.open(url)
        }
    }
    
    func didSavePSBT() {
        DispatchQueue.main.async() {
            self.appState.psbtManager.signed = true
        }
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 20.0){
                Button(action: {
                    self.vc!.openPSBT(self.openPSBT)
                }) {
                    Text("Load PSBT")
                }
                .disabled(!self.appState.walletManager.hasWallet || self.appState.psbtManager.psbt != nil)
                if self.appState.psbtManager.psbt != nil {
                    if self.appState.psbtManager.signed {
                        Text("Signed Transaction")
                    } else {
                        Text("Proposed Transaction")
                    }
                    if self.appState.psbtManager.destinations != nil {
                        ForEach(self.appState.psbtManager.destinations!.filter({ (dest) -> Bool in
                            return !dest.isChange;
                        })) { destination in
                            Text(destination.description).font(.system(.body, design: .monospaced))
                        }
                        Text("Fee: " + appState.psbtManager.fee)
                    }
                    Button(action: {
                        let signedPsbt = Signer.signPSBT(self.appState.psbtManager.psbt!)
                        // We've signed, but there's no seperate save button yet
                        // self.appState.psbtManager.signed = true
                        self.vc!.savePSBT(signedPsbt, self.didSavePSBT)
                    }) {
                        Text("Sign")
                    }
                    .disabled(!appState.psbtManager.canSign || appState.psbtManager.signed)
                    Button(action: {
                        self.appState.psbtManager.clear()
                    }) {
                        Text("Clear")
                    }
                }
            }
        }
    }
}

