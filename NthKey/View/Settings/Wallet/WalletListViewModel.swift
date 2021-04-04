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

    private let loadFileController: SettingsViewController = SettingsViewController()
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

    func addWalletByFile() {
        loadFileController.loadWallet { [weak self] url in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
                self?.dataManager.loadWalletUsingData(data) { result in
                    switch result {
                        case .failure(let error):
                            print(error)
                            break
                        case .success(let successString):
                            print(successString)
                            break
                    }
                }
            } catch {
                NSLog("Something went wrong parsing JSON file")
                return
            }
        }
    }

    func deleteWallet(_ wallet: WalletEntity) {
        dataManager.removeWallet(wallet)
    }
}
