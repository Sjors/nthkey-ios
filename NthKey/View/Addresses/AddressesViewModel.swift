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

    var errorAlertTitle: String {
        switch scanQRError {
        case .wrongEncoding, .badInputOutput, .addressNotInList:
            return "Scan address error"
        default:
            return "Import PSBT error"
        }
    }

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
                let suffixSeparator: Character = ":"
                guard code.contains(suffixSeparator),
                      var suffix = code.split(separator: suffixSeparator).last,
                      !suffix.isEmpty else {
                    self.scanQRError = .wrongEncoding
                    return
                }

                let prefixSeparator: Character = "?"
                if suffix.contains(prefixSeparator),
                   let prefix = suffix.split(separator: prefixSeparator).first,
                   !prefix.isEmpty {
                    suffix = prefix
                }

                let address = String(suffix).lowercased()
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
