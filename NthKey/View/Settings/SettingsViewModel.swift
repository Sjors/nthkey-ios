//
//  SettingsViewModel.swift
//  SettingsViewModel
//
//  Created by Sergey Vinogradov on 24.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import CodeScanner

final class SettingsViewModel: ObservableObject {
    @Published var activeSheet: SettingsView.ActiveSheet?
    @Published var hasSeed: Bool = UserDefaults.fingerprint != nil

    private let dataManager: DataManager
    private let subsManager: SubscriptionManager

    let announceModel: AnnounceViewModel
    let importWalletModel: ImportWalletViewModel
    let walletListModel: WalletListViewModel
    let codeSignersModel: CodeSignersViewModel
    let subsViewModel: SubscriptionViewModel

    init(dataManager: DataManager, subsManager: SubscriptionManager) {
        self.dataManager = dataManager
        self.subsManager = subsManager

        announceModel = AnnounceViewModel(subsManager: subsManager)
        importWalletModel = ImportWalletViewModel(dataManager: dataManager, subsManager: subsManager)
        walletListModel = WalletListViewModel(dataManager: dataManager)
        codeSignersModel = CodeSignersViewModel(dataManager: dataManager)
        subsViewModel = SubscriptionViewModel(subsManager: subsManager)
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        activeSheet = nil
        switch result {
        case .success(let code):
            DispatchQueue.main.async() { [weak self] in
                guard let data = code.data(using: .utf8) else {
                    // TODO: show error
                    return
                }
                self?.dataManager.loadWalletUsingData(data) { result in
                    // TODO: show error or success
                }
            }
        case .failure(let error):
            // TODO: show error
            print("Scanning failed")
            print(error)
        }
    }
}

#if DEBUG
extension SettingsViewModel {
    static var mock: SettingsViewModel {
        let model = SettingsViewModel(dataManager: DataManager.preview, subsManager: SubscriptionManager.mock)
        model.hasSeed = true
        if let first = model.walletListModel.items.first {
            model.walletListModel.selectedWallet = first
        }
        return model
    }

    static let notSeeded: SettingsViewModel = SettingsViewModel(dataManager: DataManager.preview, subsManager: SubscriptionManager.mock)
}
#endif
