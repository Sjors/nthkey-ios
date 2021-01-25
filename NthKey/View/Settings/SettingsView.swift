//
//  SettingsView.swift
//  SettingsView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI
import Combine
import CodeScanner
import LibWally

struct SettingsView : View {

    @EnvironmentObject var appState: AppState

    @State private var showMnemonic = false
    @State private var isShowingScanner = false
    @State private var enterMnemonnic = false
    @State private var mnemonicInput = ""
    @State private var validMnemonic = false
    @State private var promptMainnet = false

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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
    }
}
