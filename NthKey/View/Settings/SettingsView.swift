//
//  SettingsView.swift
//  SettingsView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import CodeScanner

struct SettingsView : View {

    @EnvironmentObject var appState: AppState

    @State private var showMnemonic = false
    @State private var isShowingScanner = false
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false
    @State private var promptMainnet = false
    @State private var showScanError: CodeScannerView.ScanError?

    private let settings = SettingsViewController()
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20.0) {
                
                if self.appState.walletManager.hasSeed {
                    
                    AnnounceView(manager: self.appState.walletManager, settings: settings)
                    
                    Spacer()
                    
                    WalletView(isShowingScanner: self.isShowingScanner, settings: settings)
                    
                    Spacer()
                    
                    CodeSignersView()
                        .environmentObject(self.appState)
                    
                    MiscSettings()
                        .environmentObject(self.appState)
                    
                } else {
                    NoSeedView()
                        .environmentObject(self.appState)
                }
            }
            .padding(10)
            
        }.sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
        }
        .alert(item: $showScanError) {_ in
            Alert(title: Text("Scanning failed"),
                  message: Text("Error: \(showScanError?.id ?? -1)"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Helpers
    
    private func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            DispatchQueue.main.async() {
                self.appState.walletManager.loadWallet(code.data(using: .utf8)!)
            }
        case .failure(let error):
            print("Scanning failed")
            print(error)
        }
    }
    
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let view = SettingsView()
            .environmentObject(AppState())
        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif

extension CodeScannerView.ScanError: Identifiable {
    public var id: Int {
        self.hashValue
    }
}
