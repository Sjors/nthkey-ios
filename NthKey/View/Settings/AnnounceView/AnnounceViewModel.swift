//
//  AnnounceViewModel.swift
//  AnnounceViewModel
//
//  Created by Sergey Vinogradov on 29.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import UIKit
import Combine

final class AnnounceViewModel: ObservableObject {
    @Published var network: WalletNetwork = .testnet
    @Published var showPubKeyQR = false

    var hasSubscription: Bool = false

    var pubKeyImage: UIImage? {
        QRCodeBuilder.generateQRCode(from: ourPubKey)
    }

    private var ourPubKey: Data {
        SeedManager.ourPubKey(network: network.networkValue)
    }

    var selectMainnetAfterPurchase = false

    private let subsManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()
    private let fileSaveController: SettingsViewController = SettingsViewController()

    init(subsManager: SubscriptionManager) {
        self.subsManager = subsManager

        setupObservables()
    }

    func exportPublicKey() {
        fileSaveController.exportPublicKey(data: ourPubKey)
    }

    private func setupObservables() {
        subsManager
            .$hasSubscription
            .sink { [weak self] value in
                guard let self = self else { return }
                self.hasSubscription = value

                guard self.selectMainnetAfterPurchase && value else { return }
                self.selectMainnetAfterPurchase = false
                self.network = .mainnet
            }
            .store(in: &cancellables)
    }
}
