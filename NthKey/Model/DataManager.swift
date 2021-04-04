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
    @Published var cosigners: [CosignerEntity] = []

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

        fetchWallets()

        /// Load previously selected wallet
        if let value = UserDefaults.currentWalletDescriptor {
            currentWallet = walletList.filter { $0.receive_descriptor == value }.first
        }
    }

    private func setupObservables() {
        $currentWallet
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }

                guard let wallet = value else {
                    self.addressList.removeAll()
                    self.cosigners.removeAll()
                    return
                }
                UserDefaults.currentWalletDescriptor = wallet.receive_descriptor

                let sortDesc = NSSortDescriptor(keyPath: \AddressEntity.receiveIndex, ascending: true)
                if let items = wallet.addresses,
                   let itemsArray = items.sortedArray(using: [sortDesc]) as? [AddressEntity] {

                    self.addressList = itemsArray
                }

                if let items = wallet.cosigners,
                    let itemsArray = items.allObjects as? [CosignerEntity] {
                    self.cosigners = itemsArray
                }
            }
            .store(in: &cancellables)
    }

    private func fetchWallets() {
        do {
            walletList =  try store.container.viewContext.fetch(walletsRequest)
        } catch {
            walletList = []
            self.error = error
        }
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
                guard let first = items.first(where: { item -> Bool in
                    guard let label = item.label else { return false }
                    return label.contains("A ")
                }) else { return }
                result.currentWallet = first
            }
            .store(in: &result.cancellables)
        result.prepareData()

        return result
    }()

    static let empty: DataManager = DataManager(store: PersistentStore(inMemory: true))
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

/// Wallet
extension DataManager {
    /// Load wallet and save it in DB and return a name of the wallet.
    func loadWalletUsingData(_ data: Data, completion: @escaping (Result<String, DataProcessingError>) -> Void) {
        guard let fingerprints = UserDefaults.fingerprints else {
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

            var receivedNetwork: Network = .testnet
            var ourHexString: String = ""
            guard desc.extendedKeys.contains(where: { (key) -> Bool in
                var result = false
                for (networkKey, fingerprint) in fingerprints {
                    guard key.fingerprint == fingerprint.hexString,
                          let net = Network.valueFromStringKey(networkKey) else { continue }
                    result = true
                    receivedNetwork = net
                    ourHexString = fingerprint.hexString
                }
                return result
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
            wallet.network = receivedNetwork.int16Value
            wallet.receive_descriptor = descriptor

            if let label = jsonResult["label"] as? String {
                wallet.label = label
            }

            for (key, hdKey) in hdKeys {
                let signer = CosignerEntity(context: store.container.viewContext)
                signer.name = ""
                signer.fingerprint = Data(key.fingerprint)
                signer.derivation = BIP32Path(key.origin)?.description
                signer.xpub = hdKey.description
                wallet.addToCosigners(signer)
            }

            for idx in 0..<1000 {
                let address = MultisigAddress(
                    threshold: UInt(threshold),
                    receiveIndex: UInt(idx),
                    network: receivedNetwork)

                let item = AddressEntity(context: store.container.viewContext)
                item.receiveIndex = Int32(idx)
                item.address = address.description

                wallet.addToAddresses(item)
            }

            self.fetchWallets()
            self.store.saveData()

            completion(.success(wallet.label ?? ""))
        default:
            completion(.failure(.wrongDescriptor))
        }
    }

    func removeWallet(_ wallet: WalletEntity) {
        print("Remove wallet: \(wallet.label ?? "N/A")")
        if currentWallet == wallet {
            UserDefaults.standard.remove(key: .currentWalletDescriptor)
            currentWallet = nil
        }

        store.container.viewContext.delete(wallet)
        self.store.saveData()
        fetchWallets()
    }
}
