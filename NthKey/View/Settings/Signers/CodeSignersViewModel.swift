//
//  CodeSignersViewModel.swift
//  CodeSignersViewModel
//
//  Created by Sergey Vinogradov on 28.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

final class CodeSignersViewModel: ObservableObject {
    @Published var items: [CosignerEntity] = []

    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()

    var hasOwnFingerprint: Bool {
        dataManager.currentWallet != nil
    }
    
    var ourFingerprintString: String {
        UserDefaults.fingerprint?.hexString ?? "N/A"
    }

    var threshold: Int {
        Int(dataManager.currentWallet?.threshold ?? 0)
    }

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        setupObservables()
    }

    private func setupObservables() {
        dataManager
            .$cosigners
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
}
