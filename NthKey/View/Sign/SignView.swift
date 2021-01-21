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
import CodeScanner

struct SignView : View {
    @EnvironmentObject var appState: AppState

    @State private var isShowingScanner = false
    
    var vc: SignViewController? = nil
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        switch result {
        case .success(let code):
            DispatchQueue.main.async() {
                self.appState.psbtManager.loadPSBT(code)
            }
        case .failure(let error):
            print("Scanning failed")
            print(error)
        }
    }
    
    // TODO: deduplicate QR display code from SettingsView
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
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
        ScrollView {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 20.0){
                    Button(action: {
                        self.isShowingScanner = true
                    }) {
                        Text("Scan PSBT")
                    }
                    .disabled(!self.appState.walletManager.hasWallet || self.appState.psbtManager.psbt != nil)
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
                            let psbt = Signer.signPSBT(self.appState.psbtManager.psbt!)
                            self.appState.psbtManager.signed = true
                            self.appState.psbtManager.psbt = psbt
                        }) {
                            Text("Sign")
                        }
                        .disabled(!appState.psbtManager.canSign || appState.psbtManager.signed)
                        if (appState.psbtManager.signed) {
                            Image(uiImage: generateQRCode(from: self.appState.psbtManager.psbt!.description))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350, height: 350)
                        }
                        if (appState.psbtManager.signed) {
                            Button(action: {
                                self.vc!.savePSBT(self.appState.psbtManager.psbt!, self.didSavePSBT)
                            }) {
                                Text("Save")
                            }
                        }
                        if (appState.psbtManager.signed) {
                            Button(action: {
                                UIPasteboard.general.string = self.appState.psbtManager.psbt!.description
                            }) {
                                Text("Copy")
                            }
                        }
                        Button(action: {
                            self.appState.psbtManager.clear()
                        }) {
                            Text("Clear")
                        }
                    }
                }
            }
        }.sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
        }
    }
}


struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        SignView()
            .environmentObject(AppState())
    }
}
