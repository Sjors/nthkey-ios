//
//  SettingsViewModel.swift
//  SettingsViewModel
//
//  Created by Sergey Vinogradov on 24.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

final class SettingsViewModel {
    private let dataManager: DataManager

    let walletListModel: WalletListViewModel

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        walletListModel = WalletListViewModel(dataManager: dataManager)
    }
}
