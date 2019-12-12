//
//  BitcoinCoreImport.swift
//  BitcoinCoreImport
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

public struct BitcoinCoreImport {
    struct ImportDescriptorsRPC : Codable {
        var requests: [Request]
        
        struct Request: Codable {
            var desc: String
            var timestamp: String
            var range: UInt
            var watchonly: Bool
            var internalKey: Bool
            var active: Bool
            
            private enum CodingKeys : String, CodingKey {
                case desc, timestamp, range, watchonly, internalKey = "internal", active
            }
        }
    }

    public let signers: [Signer]
    public let threshold: UInt
    public let network: Network
    
    public init?(_ signers: [Signer], threshold: UInt) {
        self.signers = signers
        self.threshold = threshold
        if signers.count < 2 { return nil }
        if threshold > signers.count { return nil }
        self.network = signers[0].hdKey.network
        for signer in signers {
            if signer.hdKey.network != self.network {return nil}
        }
    }

    public var importDescriptorsRPC: String {
        let requests: [ImportDescriptorsRPC.Request] = [false, true].map {internalKey in
            let keys = signers.map { signer in
                let cointype: String
                switch (network) {
                case .mainnet:
                    cointype = "0h"
                case .testnet:
                    cointype = "1h"
                }
                let origin = "\(signer.fingerprint.hexString)/48h/\(cointype)/0h/2h"
                return "[\(origin)]\(signer.hdKey.xpub)/\(internalKey ? "1" : "0")/*"
            }.joined(separator: ",")
            let checksum = "00000000" // TODO: calculate descriptor checksum
            return ImportDescriptorsRPC.Request(desc: "wsh(sortedmulti(\(self.threshold),\(keys)))#\(checksum)",
                timestamp: "now", range: 1000, watchonly: true, internalKey: internalKey, active: true)
        }
        let rpc = ImportDescriptorsRPC(requests: requests)
        
        let encoder = JSONEncoder()
        let argRequestsData = try! encoder.encode(rpc.requests)
        let argRequestsString = String(data: argRequestsData, encoding: .utf8)!
        let bitcoinCli = "src/bitcoin-cli" // TODO: drop src/ once we can use a release binary
        let walletName = "iOsMulti"
        var networkString: String = ""
        switch network {
        case .mainnet:
            break
        case .testnet:
            networkString = " -testnet"
        }
        return "\(bitcoinCli)\(networkString) -rpcwallet=\"\(walletName)\" importdescriptors '\(argRequestsString)'"
    }

}
