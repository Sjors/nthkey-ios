//
//  SettingsView.swift
//  SettingsView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI

struct SettingsView : View {
    
    @ObservedObject var defaults = UserDefaultsManager()
    
    let settings = SettingsViewController()
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 20.0){
                Button(action: {
                    self.settings.exportPublicKey()
                }) {
                    Text("Export public key")
                }
                Button(action: {
                    self.settings.exportBitcoinCore()
                }) {
                    Text("Export to Bitcoin Core")
                }
                .disabled(!self.defaults.hasCosigners)
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
    }
}
