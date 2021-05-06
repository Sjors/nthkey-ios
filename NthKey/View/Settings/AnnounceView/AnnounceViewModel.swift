//
//  AnnounceViewModel.swift
//  AnnounceViewModel
//
//  Created by Sergey Vinogradov on 29.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import UIKit

final class AnnounceViewModel: ObservableObject {
    @Published var network: WalletNetwork = .testnet
    @Published var showPubKeyQR = false

    var hasSubscription: Bool {
        subsManager.hasSubscription
    }

    var pubKeyImage: UIImage? {
        QRCodeBuilder.generateQRCode(from: ourPubKey)
    }

    private var ourPubKey: Data {
        SeedManager.ourPubKey(network: network.networkValue)
    }

    private let subsManager: SubscriptionManager
    private let fileSaveController: SettingsViewController = SettingsViewController()

    init(subsManager: SubscriptionManager) {
        self.subsManager = subsManager
    }

    func exportPublicKey() {
        fileSaveController.exportPublicKey(data: ourPubKey)
    }
}
