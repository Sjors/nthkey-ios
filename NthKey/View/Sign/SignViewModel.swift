//
//  SignViewModel.swift
//  SignViewModel
//
//  Created by Sergey Vinogradov on 29.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import UIKit
import Combine
import CodeScanner
import LibWally

class SignViewModel: ObservableObject {
    @Published private(set) var state: State = State.initial
    @Published var isShowingScanner = false
    @Published var errorMessage: String?

    var psbtSignedImage: UIImage {
        var result = "Here should be a PSBT signed data"
        if let signed = psbt?.description {
            result = signed
        }
        return QRCodeBuilder.generateQRCode(from: result)
    }

    private var psbt: PSBT?
    var destinations: [Destination] = []
    var feeString: String = ""

    private let dataManager: DataManager
    private let fileOperationsController = SignViewController()
    private var cancellables = Set<AnyCancellable>()

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        setupObservables()
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let psbtString):
            DispatchQueue.main.async() { [weak self] in
                self?.loadPsbtString(psbtString)
            }
        case .failure(let error):
            self.errorMessage = "Scanning failed: \(error.localizedDescription)"
        }
    }

    func loadFile() {
        fileOperationsController.openPSBT { [weak self] url in
            DispatchQueue.main.async() {
                self?.openPsbtUrl(url)
            }
        }
    }

    func sign() {
        guard let unsigned = psbt else { return }
        psbt = Signer.signPSBT(unsigned)
        state = .signed
    }

    func saveFile() {
        guard let signed = psbt else { return }
        fileOperationsController.savePSBT(signed) {}
    }

    func copyToClipboard() {
        guard let signed = psbt else { return }
        UIPasteboard.general.string = signed.description
    }

    func clear() {
        psbt = nil
        destinations = []
        state = dataManager.currentWallet == nil ? .initial : .canLoad // TODO: DRY
    }

    func openPsbtUrl(_ url: URL) {
        guard let network = dataManager.currentWallet?.wrappedNetwork else { return }
        do {
           let payload = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
            let psbt = try PSBT(payload, network)
            processPSBT(psbt)
        } catch {
           errorMessage = "Something went wrong parsing PSBT file"
        }
    }

    // MARK: - Private

    private func setupObservables() {
        dataManager
            .$currentWallet
            .map{ $0 != nil ? State.canLoad : State.initial }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func loadPsbtString(_ string: String) {
        guard let network = dataManager.currentWallet?.wrappedNetwork else { return }
        do {
            let psbt = try PSBT(string, network)
            processPSBT(psbt)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func processPSBT(_ psbt: PSBT) {
        guard let wallet = dataManager.currentWallet else { return }
        state = .loaded

        self.psbt = psbt

        let hdKeys = wallet.cosignersHDKeys
        self.destinations = psbt.outputs.map { output in
            return Destination(output: output,
                               inputs: psbt.inputs,
                               threshold: UInt(wallet.threshold),
                               cosignerKeys: hdKeys)
        }

        if let fee = psbt.fee {
            self.feeString = "Fee: \(fee) sats"
        }
        let us = Signer.getOurselfSigner()
        var canBeSigned = false
        for input in psbt.inputs {
            canBeSigned = canBeSigned || input.canSign(us.hdKey) as Bool
        }
        if canBeSigned {
            state = .canSign
        }
    }
}

// MARK: FSM
extension SignViewModel {
    enum State {
        case initial
        case canLoad
        case loaded
        case canSign
        case signed
    }
}

#if DEBUG
extension SignViewModel {
    static var mocks = Mocks()

    private func preparePSBT(_ psbt: PSBT) {
        self.psbt = psbt
        if let fee = PSBT.mock.fee {
            self.feeString = "Fee: \(fee) sats"
        }

        // TODO: SeedManager also should be mocked
        /*
        UserDefaults.fingerprint = Data("52a40f37")!

        let hdKeys = [HDKey("tpubDF9imPRCbD8oNH3cuQv5WWhWKUM6kMtTRY3i2AizLXzau7G6Ptak2cXAAxCjDXxZNt2GvT2Gnp7d7gtrficYRQJUPSNGaJxh3KF4NcoCuyi")!]

        self.destinations = psbt.outputs.map { output in
            return Destination(output: output,
                               inputs: psbt.inputs,
                               threshold: UInt(1),
                               cosignerKeys: hdKeys)
        }
         */
    }
    
    struct Mocks {
        var unselected = SignViewModel(dataManager: DataManager.empty)

        var canLoad = SignViewModel(dataManager: DataManager.preview)

        var loaded: SignViewModel {
            let result = SignViewModel(dataManager: DataManager.preview)

            result.preparePSBT(PSBT.mock)
            result.state = .loaded

            return result
        }

        var canSign: SignViewModel {
            let result = SignViewModel(dataManager: DataManager.preview)

            result.preparePSBT(PSBT.mock)
            result.state = .canSign

            return result
        }

        var signed: SignViewModel {
            let result = SignViewModel(dataManager: DataManager.preview)

            result.preparePSBT(PSBT.mock)
            result.state = .signed

            return result
        }
    }
}
#endif
