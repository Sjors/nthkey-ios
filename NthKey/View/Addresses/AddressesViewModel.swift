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
    @Published var showScanner: Bool = false
    @Published var scanQRError: DataProcessingError?
    @Published private(set) var addressToScroll: String?

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
        showScanner = false
        
        switch result {
        case .success(let code):
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                let separator: Character = ":"
                guard code.contains(separator),
                      let suffix = code.split(separator: separator).last,
                      !suffix.isEmpty else {
                    self.scanQRError = .wrongEncoding
                    return
                }

                let address = String(suffix)
                if let index = self.items.firstIndex(where: { $0.address == address }) {
                    #if DEBUG
                    print("Let's scroll to: \(index)")
                    #endif
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                        self?.addressToScroll = address
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                        self?.scanQRError = .addressNotInList
                    }
                }
            }
        case .failure(let error):
            scanQRError = .badInputOutput
            #if targetEnvironment(simulator)
            print("Scanning failed: \(error)")
            #endif
        }
    }
}
