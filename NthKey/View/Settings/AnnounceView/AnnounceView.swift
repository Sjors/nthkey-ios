//
//  AnnounceView.swift
//  AnnounceView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct AnnounceView: View {
    @ObservedObject var model: AnnounceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            NetworkPickerView(network: $model.network)
            
            Text("In Specter go to 'Add new device', select Other and scan the QR code.")

            Button(model.showPubKeyQR ? "Hide QR" : "Show QR \(model.network.title)") {
                model.showPubKeyQR.toggle()
            }

            if model.showPubKeyQR,
               let qrCodeImage = model.pubKeyImage {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
            }

            Button("Save as JSON \(model.network.title)") {
                model.exportPublicKey()
            }
        }
    }
}

#if DEBUG
struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        // FIXME: Add wallet manager mock with pubkey for preview
        let view = AnnounceView(model: AnnounceViewModel())
        
        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
