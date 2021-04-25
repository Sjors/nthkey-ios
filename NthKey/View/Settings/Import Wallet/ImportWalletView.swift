//
//  ImportWalletView.swift
//  ImportWalletView
//
//  Created by Sergey Vinogradov on 25.04.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct ImportWalletView: View {
    @ObservedObject var model: ImportWalletViewModel

    @Binding var isShowingScanner: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NetworkPickerView(network: $model.selectedNetwork)
            
            Button(action: {
                isShowingScanner = true
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Scan wallet QR code")
                }
                .foregroundColor(.accentColor)
            }
            Button(action: {
                model.addWalletByFile()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Import wallet JSON")
                }
                .foregroundColor(.accentColor)
            }
        }
        .alert(item: $model.loadWalletError) { error in
            Alert(title: Text("Load wallet error"),
                  message: Text(error.errorDescription ?? "Unknown error"),
                  dismissButton: .cancel())
        }
    }
}

#if DEBUG
struct ImportWalletView_Previews: PreviewProvider {
    static var previews: some View {
        ImportWalletView(model: ImportWalletViewModel(dataManager: DataManager.preview),
                         isShowingScanner: .constant(false))
    }
}
#endif
