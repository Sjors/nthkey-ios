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
            Text("In Specter go to 'Add new device', select Other and scan the QR code.")

            Picker(selection: $model.networkIndex, label: Text("Select Network")) {
                ForEach(0..<model.networkTitles.count) {
                    Text(model.networkTitles[$0])
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Button(model.showPubKeyQR ? "Hide QR" : "Show QR \(model.networkTitle)") {
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

            Button("Save as JSON \(model.networkTitle)") {
                model.exportPublicKey()
            }
        }
    }
}

#if DEBUG
struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        // FIXME: Add wallet manager mock with pubkey for preview
        let view = AnnounceView(model: AnnounceViewModel(manager: AppState().walletManager))
        
        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
