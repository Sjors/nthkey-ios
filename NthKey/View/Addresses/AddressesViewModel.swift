//
//  AddressesViewModel.swift
//  AddressesViewModel
//
//  Created by Sergey Vinogradov on 12.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

class AddressesViewModel: ObservableObject {
    @Published var items: [AddressEntity] = []

    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        setupObservables()
    }

    private func setupObservables() {
        dataManager
            .$addressList
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
}

#if DEBUG
extension AddressesViewModel {
    static var mock: AddressesViewModel = AddressesViewModel(dataManager: DataManager.preview)
}
#endif
