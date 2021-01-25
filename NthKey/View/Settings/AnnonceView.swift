//
//  AnnonceView.swift
//  AnnonceView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AnnounceView: View {
    
    @State private var showPubKeyQR = false
    
    private let manager: WalletManager
    private let settings: SettingsViewController
    init(manager: WalletManager, settings: SettingsViewController) {
        self.manager = manager
        self.settings = settings
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Announce").font(.headline)
            Text("In Specter go to 'Add new device', select Other and scan the QR code.")
        }
        
        Button(action: {
            self.showPubKeyQR.toggle()
        }) {
            Text(self.showPubKeyQR ? "Hide QR" : "Show QR")
        }
        
        if (self.showPubKeyQR) {
            let qrCodeImage = QRCodeBuilder.generateQRCode(from: self.manager.ourPubKey())!
            Image(uiImage: qrCodeImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
        }
        
        Button(action: {
            self.settings.exportPublicKey(data: self.manager.ourPubKey())
        }) {
            Text("Save as JSON")
        }
        
    }
}

struct AnnonceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceView(manager: AppState().walletManager, settings: SettingsViewController())
    }
}
