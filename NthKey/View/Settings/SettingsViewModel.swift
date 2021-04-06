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
    @Published var isShowingScanner = false

    private let dataManager: DataManager

    let walletListModel: WalletListViewModel
    let codeSignersModel: CodeSignersViewModel

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        walletListModel = WalletListViewModel(dataManager: dataManager)
        codeSignersModel = CodeSignersViewModel(dataManager: dataManager)
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isShowingScanner = false
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
        let model = SettingsViewModel(dataManager: DataManager.preview)
        if let first = model.walletListModel.items.first {
            model.walletListModel.selectedWallet = first
        }
        return model
    }
}
#endif
