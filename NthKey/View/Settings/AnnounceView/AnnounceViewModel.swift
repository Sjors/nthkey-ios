//
//  AnnounceViewModel.swift
//  AnnounceViewModel
//
//  Created by Sergey Vinogradov on 29.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import UIKit
import Combine
import LibWally

final class AnnounceViewModel: ObservableObject {
    @Published var network: WalletNetwork = .testnet
    @Published var showPubKeyQR = false

    private var cancellables = Set<AnyCancellable>()

    private let fileSaveController: SettingsViewController = SettingsViewController()
    private let manager: SeedManager

    var pubKeyImage: UIImage? {
        QRCodeBuilder.generateQRCode(from: self.manager.ourPubKey(network: network.networkValue))
    }
    
    init(manager: SeedManager) {
        self.manager = manager
    }

    func exportPublicKey() {
        fileSaveController.exportPublicKey(data: manager.ourPubKey(network: network.networkValue))
    }
}
