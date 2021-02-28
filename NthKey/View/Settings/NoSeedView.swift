//
//  NoSeedView.swift
//  NoSeedView
//
//  Created by Fathi on 25/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Combine
import SwiftUI
import LibWally

struct NoSeedView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Your keys").font(.headline)
            Text("The app generates a fresh cryptographic key for you, or you can recover from a backup by entering its 24 words.")

            Button("Generate fresh keys") {
                self.appState.walletManager.generateSeed()
            }
            .disabled(self.enterMnemonnic)

            Button("Recover from backup") {
                self.enterMnemonnic.toggle()
            }

            if self.enterMnemonnic {
                TextField("battery staple horse...", text: $mnemonicInput)
                    .keyboardType(.alphabet)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .onReceive(Just(mnemonicInput)) { newValue in
                        // TODO:
                        // * check every word against BIP39Words
                        // * suggest autocomplete for each
                        let words: [String] = newValue.components(separatedBy: " ")
                        if words.count == 12 || words.count == 16 || words.count == 24 {
                            // TODO:
                            // * make BIP39Mnemonic do the above check
                            // * make isValid public
                            self.validMnemonic = LibWally.BIP39Mnemonic(words) != nil
                        } else {
                            self.validMnemonic = false
                        }
                    }
                Button("OK") {
                    let words: [String] = self.mnemonicInput.components(separatedBy: " ")
                    self.appState.walletManager.setEntropy(LibWally.BIP39Mnemonic(words)!.entropy)
                }
                .disabled(!self.validMnemonic)
            }
        }
    }
}

#if DEBUG
struct NoSeedView_Previews: PreviewProvider {
    static var previews: some View {
        let view = NoSeedView()

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
        .environmentObject(AppState())
    }
}
#endif
