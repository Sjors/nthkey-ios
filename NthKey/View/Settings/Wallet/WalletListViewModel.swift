//
//  WalletListViewModel.swift
//  WalletListViewModel
//
//  Created by Sergey Vinogradov on 21.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import CoreData

final class WalletListViewModel: ObservableObject {
    @Published var selectedWallet: WalletEntity?
    @Published var items: [WalletEntity] = []

    private let store: PersistentStore
    private let request = NSFetchRequest<WalletEntity>(entityName: "WalletEntity")

    init(store: PersistentStore) {
        self.store = store

        request.sortDescriptors = [NSSortDescriptor(keyPath: \WalletEntity.label, ascending: true)]
    }

    func viewDidAppear() {
        do {
            items = try store.container.viewContext.fetch(request)
        } catch {
            items = []
            // self.error = error as NSError
        }
    }

    func addWallet() {
        
    }
}

#if DEBUG
extension WalletListViewModel {
    static var mock: WalletListViewModel {
        let model = WalletListViewModel(store: PersistentStore.preview)
        model.viewDidAppear()
        if let first = model.items.first {
            model.selectedWallet = first
        }
        return model
    }
}
#endif
