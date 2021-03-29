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
    @Published var networkIndex: Int = 0
    @Published var showPubKeyQR = false

    // Order of the networks is fixed
    let networkTitles: [String] = Network.allCases.map { $0.title }

    var networkTitle: String {
        "( \(network.title) )"
    }

    var network: Network = .testnet

    private var cancellables = Set<AnyCancellable>()

    private let fileSaveController: SettingsViewController = SettingsViewController()
    private let manager: SeedManager

    var pubKeyImage: UIImage? {
        QRCodeBuilder.generateQRCode(from: self.manager.ourPubKey(network: network))
    }
    
    init(manager: SeedManager) {
        self.manager = manager

        $networkIndex
            .sink(receiveValue: { [weak self] idx in
                guard let self = self else { return }
                self.network = Network.allCases[idx]
                if self.showPubKeyQR {
                    self.showPubKeyQR = false
                }
            })
            .store(in: &cancellables)
        
        networkIndex = 1
    }

    func exportPublicKey() {
        fileSaveController.exportPublicKey(data: manager.ourPubKey(network: network))
    }
}
