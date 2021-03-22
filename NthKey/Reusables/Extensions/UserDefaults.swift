//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by Sergey Vinogradov on 28/02/2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

@propertyWrapper
struct UserDefault <Value> {
    let key: UserDefaults.Keys
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get { return container.object(forKey: key.rawValue) as? Value ?? defaultValue }
        set { container.set(newValue, forKey: key.rawValue) }
    }
}

extension UserDefaults {
    enum Keys: String {
        case cosigners = "cosigners"
        case hasWallet = "hasWallet"
        case threshold = "threshold"
        case fingerprint = "masterKeyFingerprint"
        case mainnet = "mainnet"
        case entropyMask = "entropyMask"

        case currentWalletDescriptor = "walletReceivedDescriptor"
    }
}

extension UserDefaults {
    @UserDefault(key: Keys.cosigners, defaultValue: [])
    static var cosigners: [Data]

    @UserDefault(key: Keys.hasWallet, defaultValue: false)
    static var hasWallet: Bool

    @UserDefault(key: Keys.threshold, defaultValue: 0)
    static var threshold: Int

    @UserDefault(key: Keys.fingerprint, defaultValue: nil)
    static var fingerprint: Data?

    @UserDefault(key: Keys.mainnet, defaultValue: false)
    static var mainnet: Bool

    @UserDefault(key: Keys.entropyMask, defaultValue: nil)
    static var entropyMask: Data?

    @UserDefault(key: Keys.currentWalletDescriptor, defaultValue: nil)
    static var currentWalletDescriptor: String?

    func remove(key: UserDefaults.Keys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
