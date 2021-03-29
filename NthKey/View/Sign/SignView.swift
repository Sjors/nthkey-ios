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
    @ObservedObject var model: SignViewModel
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
                    Button("Scan PSBT") {
                        self.isShowingScanner = true
                    }
                    .disabled(!model.hasWallet || self.appState.psbtManager.psbt != nil)

                    Button("Load PSBT") {
                        self.vc!.openPSBT(self.openPSBT)
                    }
                    .disabled(!model.hasWallet || self.appState.psbtManager.psbt != nil)

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

                        Button("Sign") {
                            let psbt = Signer.signPSBT(self.appState.psbtManager.psbt!)
                            self.appState.psbtManager.signed = true
                            self.appState.psbtManager.psbt = psbt
                        }
                        .disabled(!appState.psbtManager.canSign || appState.psbtManager.signed)

                        if (appState.psbtManager.signed) {
                            Image(uiImage: generateQRCode(from: self.appState.psbtManager.psbt!.description))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350, height: 350)

                            Button("Save") {
                                self.vc!.savePSBT(self.appState.psbtManager.psbt!, self.didSavePSBT)
                            }

                            Button("Copy") {
                                UIPasteboard.general.string = self.appState.psbtManager.psbt!.description
                            }
                        }
                        Button("Clear") {
                            self.appState.psbtManager.clear()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
        }
    }
}

#if DEBUG
struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        // FIXME: Add mockups to present all cases
        let view = SignView(model: SignViewModel(dataManager: DataManager.preview))
            .environmentObject(AppState())

        let emptyView = SignView(model: SignViewModel(dataManager: DataManager.empty))
            .environmentObject(AppState())

        return Group {
            view

            emptyView

            NavigationView { view }
                .colorScheme(.dark)

            NavigationView { emptyView }
                .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 350, height: 170))
    }
}
#endif
