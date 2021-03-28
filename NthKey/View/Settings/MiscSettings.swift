//
//  MiscSettings.swift
//  MiscSettings
//
//  Created by Fathi on 25/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct MiscSettings: View {
    @EnvironmentObject var appState: AppState
    
    @State private var showMnemonic = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Misc").font(.headline)
            Button("Show mnemonic") {
                self.showMnemonic = true
            }
            .alert(isPresented: $showMnemonic) {
                Alert(title: Text("BIP 39 mnemonic"), message: Text(self.appState.walletManager.mnemonic()), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#if DEBUG
struct MiscSettings_Previews: PreviewProvider {
    static var previews: some View {
        let view = MiscSettings()
            .environmentObject(AppState())

        return Group {
            view

            NavigationView {
                view
            }
                .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 350, height: 200))
    }
}
#endif
