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

// MARK: - Data processing

import OutputDescriptors
import LibWally

/// Specter interactions
enum DataProcessingError: Error, LocalizedError {
    case wrongInputData
    case unableParseDescriptor(String?)
    case wrongDescriptor
    case notEnoughKeys
    case absentOurFingerprint
    case wrongCosigner
    case wrongNumberOfCosigners
    case missedFingerprint

    public var errorDescription: String? {
        switch self {
        case .wrongInputData:
            return "JSON format not recognized"
        case .unableParseDescriptor(let descriptor): //private ParseError not allow to share more info
            return "Unable to parse descriptor: \(descriptor ?? "N/A")"
        case .wrongDescriptor:
            return "Expected sortedmulti descriptor"
        case .notEnoughKeys:
            return "Require at least 2 keys"
        case .absentOurFingerprint:
            return "We're not part of the wallet"
        case .wrongCosigner:
            return "Malformated cosigner xpub"
        case .wrongNumberOfCosigners:
            return "Cosigner count does not match descriptor keys count"
        default:
            return nil
        }
    }
}

extension DataManager {
    /// Load wallet and save it in DB and return a name of the wallet.
    func loadWalletUsingData(_ data: Data, completion: @escaping (Result<String, DataProcessingError>) -> Void) {
        guard let ourHexString = UserDefaults.fingerprint?.hexString else {
            completion(.failure(.missedFingerprint)) // our fingerprint should be filled on seed generation step
            return
        }

        // Check if it is a JSON and uses Specter format:
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let jsonResult = json as? Dictionary<String, AnyObject>,
              let descriptor = jsonResult["descriptor"] as? String else {
            completion(.failure(.wrongInputData))
            return
        }

        // Try to get descriptor
        guard let desc = try? OutputDescriptor(descriptor) else {
            completion(.failure(.unableParseDescriptor(descriptor)))
            return
        }

        switch desc.descType {
        case .sortedMulti(let threshold):
            guard desc.extendedKeys.count > 1 else {
                completion(.failure(.notEnoughKeys))
                return
            }

            guard desc.extendedKeys.contains(where: { (key) -> Bool in
                key.fingerprint == ourHexString
            }) else {
                completion(.failure(.absentOurFingerprint))
                return
            }

            var hdKeys: [(ExtendedKey, HDKey)] = []
            desc.extendedKeys.forEach { (key) in
                if (key.fingerprint == ourHexString) { return }
                let extendedKey = Data(base58: key.xpub)!
                // Check that this is a testnet tpub
                let marker = Data(extendedKey.subdata(in: 0..<4))
                if marker != Data("043587cf")! && marker != Data("0488b21e") {
                    NSLog("Expected tpub marker (0x043587cf) or xpub marker (0x0488b21e), got 0x%@", marker.hexString)
                    return
                }

                guard let aKey = HDKey(key.xpub) else {
                    completion(.failure(.wrongCosigner))
                    return
                }
                hdKeys.append((key, aKey))
            }
            guard hdKeys.count == desc.extendedKeys.count - 1 else {
                completion(.failure(.wrongNumberOfCosigners))
                return
            }

            // FIXME: Make sure that it happen in main thread
            let wallet = WalletEntity(context: store.container.viewContext)
            wallet.threshold = Int16(threshold)

            for (key, hdKey) in hdKeys {
                let signer = CosignerEntity(context: store.container.viewContext)
                signer.name = ""
                signer.fingerprint = Data(key.fingerprint)
                signer.derivation = BIP32Path(key.origin)?.description
                signer.xpub = hdKey.description
                wallet.addToCosigners(signer)
            }
        default:
            completion(.failure(.wrongDescriptor))
        }
    }
}
