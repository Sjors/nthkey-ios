//
//  SignViewModel.swift
//  SignViewModel
//
//  Created by Sergey Vinogradov on 29.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

class SignViewModel: ObservableObject {
    @Published var hasWallet: Bool = false

    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        setupObservables()
    }

    private func setupObservables() {
        dataManager
            .$walletList
            .map{ $0.count > 0 }
            .assign(to: \.hasWallet, on: self)
            .store(in: &cancellables)
    }
}
