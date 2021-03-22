//
//  DataManager.swift
//  DataManager
//
//  Created by Sergey Vinogradov on 22.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import CoreData
import Combine

/// Incapsulates all data changes and persistent store interaction inside
final class DataManager: ObservableObject {
    @Published var addressList: [AddressEntity] = []
    @Published var walletList: [WalletEntity] = []

    @Published var currentWallet: WalletEntity?

    @Published var error: Error?

    private let store: PersistentStore
    fileprivate var cancellables = Set<AnyCancellable>()

    private var dataWasPrepared = false
    private var walletsRequest: NSFetchRequest<WalletEntity>

    init(store: PersistentStore) {
        self.store = store

        walletsRequest = NSFetchRequest<WalletEntity>(entityName: "WalletEntity")
        walletsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WalletEntity.label, ascending: true)]

        setupObservables()
    }

    /// Load all needed values
    func prepareData() {
        guard !dataWasPrepared else { return }
        dataWasPrepared = true

        do {
            walletList = try store.container.viewContext.fetch(walletsRequest)

            /// Load previously selected wallet
            if let value = UserDefaults.currentWalletDescriptor {
                currentWallet = walletList.filter { $0.receive_descriptor == value }.first
            }
        } catch {
            walletList = []
            self.error = error
        }
    }

    private func setupObservables() {
        $currentWallet
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self else { return }

                guard let wallet = value else { return }
                UserDefaults.currentWalletDescriptor = wallet.receive_descriptor

                let sortDesc = NSSortDescriptor(keyPath: \AddressEntity.receiveIndex, ascending: true)
                guard let items = wallet.addresses,
                      let itemsArray = items.sortedArray(using: [sortDesc]) as? [AddressEntity] else { return }
                
                self.addressList = itemsArray
            }
            .store(in: &cancellables)


        $walletList
        .dropFirst()
        .sink { items in

            guard let first = items.first else { return }
            self.currentWallet = first
        }
        .store(in: &cancellables)
    }
}

#if DEBUG
extension DataManager {
    static var preview: DataManager = {
        let result = DataManager(store: PersistentStore.preview)

        result
            .$walletList
            .dropFirst()
            .sink { items in
                guard let first = items.first else { return }
                result.currentWallet = first
            }
            .store(in: &result.cancellables)
        result.prepareData()

        return result
    }()
}
#endif
