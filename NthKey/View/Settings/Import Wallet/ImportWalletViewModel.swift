//
//  ImportWalletViewModel.swift
//  ImportWalletViewModel
//
//  Created by Sergey Vinogradov on 25.04.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

final class ImportWalletViewModel: ObservableObject {
    @Published var selectedNetwork: WalletNetwork
    @Published var loadWalletError: DataProcessingError?

    var hasSubscription: Bool = false
    var selectMainnetAfterPurchase: Bool = false
    
    private let loadFileController: SettingsViewController = SettingsViewController()
    private let dataManager: DataManager
    private let subsManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()

    init(dataManager: DataManager, subsManager: SubscriptionManager) {
        self.dataManager = dataManager
        self.subsManager = subsManager

        if let wallet = dataManager.currentWallet,
           let network = WalletNetwork.valueFromInt16(wallet.network) {
            self.selectedNetwork = network
        } else {
            self.selectedNetwork = .testnet
        }

        setupObservables()
    }

    private func setupObservables() {
        $selectedNetwork
            .map{ $0 as WalletNetwork? }
            .assign(to: \.currentNetwork, on: self.dataManager)
            .store(in: &cancellables)

        // TODO: DRY TBC here and in AnnounceViewModel
        subsManager
            .$hasSubscription
            .sink { [weak self] value in
                guard let self = self else { return }
                self.hasSubscription = value

                guard self.selectMainnetAfterPurchase && value else { return }
                self.selectMainnetAfterPurchase = false
                self.selectedNetwork = .mainnet
            }
            .store(in: &cancellables)
    }

    func addWalletByFile() {
        loadFileController.loadWallet { [weak self] url in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
                self?.dataManager.loadWalletUsingData(data) { result in
                    switch result {
                        case .failure(let error):
                            self?.loadWalletError = error
                            break
                        case .success(_):
                            break
                    }
                }
            } catch {
                self?.loadWalletError = .wrongInputData
            }
        }
    }
}
