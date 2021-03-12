//
//  AddressesViewModel.swift
//  AddressesViewModel
//
//  Created by Sergey Vinogradov on 12.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import CoreData

class AddressesViewModel: ObservableObject {
    @Published var items: [AddressEntity] = []

    private let store: PersistentStore
    private let request = NSFetchRequest<AddressEntity>(entityName: "AddressEntity")

    init(store: PersistentStore) {
        self.store = store

        request.sortDescriptors = [NSSortDescriptor(keyPath: \AddressEntity.receiveIndex, ascending: true)]
    }

    func viewDidAppear() {
        do {
            items = try store.container.viewContext.fetch(request)
        } catch {
            items = []
            // self.error = error as NSError
        }
    }
}

#if DEBUG
extension AddressesViewModel {
    static var mock: AddressesViewModel = AddressesViewModel(store: PersistentStore.preview)
}
#endif
