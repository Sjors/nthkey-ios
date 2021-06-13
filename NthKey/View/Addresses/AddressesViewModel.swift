//
//  AddressesViewModel.swift
//  AddressesViewModel
//
//  Created by Sergey Vinogradov on 12.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine
import CodeScanner

class AddressesViewModel: ObservableObject {
    @Published var items: [AddressProxy] = []
    @Published var scanQRError: DataProcessingError?

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

    func toggleUsed(for item: AddressProxy) {
        dataManager.toggleUsedFor(item: item)
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
        case .success(let code):
            DispatchQueue.main.async() { [weak self] in
                guard let data = code.data(using: .utf8) else {
                    self?.scanQRError = .wrongEncoding
                    return
                }

                print(data)
            }
        case .failure(let error):
            scanQRError = .badInputOutput
            #if targetEnvironment(simulator)
            print("Scanning failed: \(error)")
            #endif
        }
    }
}
