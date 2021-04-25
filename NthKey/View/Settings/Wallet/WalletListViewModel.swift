//
//  WalletListViewModel.swift
//  WalletListViewModel
//
//  Created by Sergey Vinogradov on 21.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

final class WalletListViewModel: ObservableObject {
    @Published var selectedWallet: WalletEntity?
    @Published var items: [WalletEntity] = []

    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        setupObservables()
    }

    private func setupObservables() {
        dataManager
            .$walletList
            .assign(to: \.items, on: self)
            .store(in: &cancellables)

        $selectedWallet
            .dropFirst()
            .assign(to: \.currentWallet, on: self.dataManager)
            .store(in: &cancellables)
    }

    func viewDidAppear() {
        guard let value = dataManager.currentWallet else { return }
        selectedWallet = value
    }

    func deleteWallet(_ wallet: WalletEntity) {
        dataManager.removeWallet(wallet)
    }
}
