//
//  CodeSignersView.swift
//  CodeSignersView
//
//  Created by Fathi on 25/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI


struct CodeSignersView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Cosigners").font(.headline)
            Text("* \(appState.walletManager.us!.fingerprint.hexString )")
                .font(.system(.body, design: .monospaced))
                + Text(" (us)")
            ForEach(appState.walletManager.cosigners) { cosigner in
                Text("* \( cosigner.fingerprint.hexString )" )
                    .font(.system(.body, design: .monospaced))
                    + Text(cosigner.name != "" ? " (\(cosigner.name))" : "")
            }
            
            if self.appState.walletManager.hasWallet {
                Button(action: {
                    self.appState.walletManager.wipeWallet()
                }) {
                    Text("Wipe wallet")
                }
            }
        }
    }
    
}
