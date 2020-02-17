//
//  WalletComposer.swift
//  WalletComposer
//
//  Created by Sjors Provoost on 16/02/2020.
//  Copyright © 2020 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally
import OutputDescriptors

public struct WalletComposer : Codable {
    
    enum WalletComposerError: Error {
        case invalidKey
        case invalidSubPolicy
    }
    
    enum SubPolicy {
        case pk
    }
    
    public var announcements: [String:SignerAnnouncement]
    public var descriptors: [String: [String: String]]?
    public var policy: String?
    public var sub_policies: [String: String]?

    public struct SignerAnnouncement: Codable {
        var name: String
        var can_decompile_miniscript: Bool?
        var sub_policy: String?
        var keys: [String:[String:String]]?

        init(name: String, us: Bool, sub_policy: String?, keys: [String:[String:String]]?) {
            self.name = name
            self.sub_policy = sub_policy
            if (us) {
                self.can_decompile_miniscript = false
            }
            self.keys = keys
        }

    }

    public init?(us: Signer, signers: [Signer], threshold: Int? = nil) {
        let network = signers[0].hdKey.network
        self.announcements = signers.reduce(into: [:]) { announcements, signer in
            announcements[signer.fingerprint.hexString] = SignerAnnouncement(
                name: signer.name,
                us: us == signer,
                sub_policy: "pk(\(signer.fingerprint.hexString))",
                keys: [
                    "wsh":[
                        "receive": WalletComposer.key(signer: signer, network:network, internalKey: false),
                        "change": WalletComposer.key(signer: signer, network:network, internalKey: true)
                    ]
                ]
            )
        }
        if let threshold = threshold {
            self.policy = "thresh(\(threshold),\(signers.map { signer in "pk(\( signer.fingerprint.hexString ))" }.joined(separator:",") ))"
            self.descriptors = [
                "wsh":[
                    "receive": WalletComposer.descriptor(signers: signers, threshold: threshold, internalKey: false, network: network),
                    "change": WalletComposer.descriptor(signers: signers, threshold: threshold, internalKey: true, network: network)
                ]
            ]
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        announcements = try container.decode([String:SignerAnnouncement].self, forKey: .announcements)

        for announcement in announcements {
            let fingerprint = announcement.key
            if fingerprint.count != 8 {
                throw DecodingError.dataCorruptedError(
                    forKey:.announcements,
                    in: container,
                    debugDescription: """
                    Expected "\(fingerprint)" to have 8 characters
                    """
                )
            }

            guard let value = Data(fingerprint) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .announcements,
                    in: container,
                    debugDescription: """
                    Failed to convert an instance of \(Data.self) from "\(fingerprint)"
                    """
                )
            }

            if value.hexString != fingerprint {
                  throw DecodingError.dataCorruptedError(
                      forKey:.announcements,
                      in: container,
                      debugDescription: """
                      "\(fingerprint)" is not hex
                      """
                  )
            }

        }
        
    }
    
    static func key(signer: Signer, network: Network, internalKey: Bool) -> String {
        let cointype: String
        switch (network) {
        case .mainnet:
            cointype = "0h"
        case .testnet:
            cointype = "1h"
        }
        let origin = "\(signer.fingerprint.hexString)/48h/\(cointype)/0h/2h"
        return "[\(origin)]\(signer.hdKey.xpub)/\(internalKey ? "1" : "0")/*"
    }
    
    static func descriptor(signers: [Signer], threshold: Int, internalKey: Bool, network: Network) -> String {
        let keys = signers.map { signer in
            key(signer: signer, network: network, internalKey: internalKey)
        }.joined(separator: ",")
        let descriptor = "wsh(sortedmulti(\(threshold),\(keys)))"
        let desc = try! OutputDescriptor(descriptor)
        return "\(descriptor)#\(desc.checksum)"
    }
    
    static func parseKey(_ key: String, expectedFingerprint: Data) throws -> (String, String) {
        let pattern = #"^\[(?<fingerprint>[0-9a-f]{8})(?<derivation>(/\d+h)+)](?<xpub>.*)/[01]/\*$"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(key.startIndex..<key.endIndex,
        in: key)
        guard let match = regex.firstMatch(in: key, options: [], range: nsrange) else { throw WalletComposerError.invalidKey }
        let fingerprint_nsrange = match.range(withName: "fingerprint")
        guard nsrange.location != NSNotFound, let range = Range(fingerprint_nsrange, in: key) else { throw WalletComposerError.invalidKey }
        let fingerprint_match = key[range]
        guard fingerprint_match == expectedFingerprint.hexString else { throw WalletComposerError.invalidKey }
        let derivation_nsrange = match.range(withName: "derivation")
        guard nsrange.location != NSNotFound, let range2 = Range(derivation_nsrange, in: key) else { throw WalletComposerError.invalidKey }
        let derivation_match = key[range2]
        let xpub_nsrange = match.range(withName: "xpub")
        guard nsrange.location != NSNotFound, let range3 = Range(xpub_nsrange, in: key) else { throw WalletComposerError.invalidKey }
        let xpub_match = key[range3]
        return (String(derivation_match), String(xpub_match))
    }
    
    static func parseSubPolicy(_ subPolicy: String, expectedFingerprint: Data) throws -> SubPolicy {
        let pattern = #"^pk\((?<fingerprint>[0-9a-f]{8})\)$"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(subPolicy.startIndex..<subPolicy.endIndex, in: subPolicy)
        guard let match = regex.firstMatch(in: subPolicy, options: [], range: nsrange) else { throw WalletComposerError.invalidKey }
        let fingerprint_nsrange = match.range(withName: "fingerprint")
        guard nsrange.location != NSNotFound, let range = Range(fingerprint_nsrange, in: subPolicy) else { throw WalletComposerError.invalidSubPolicy }
        let fingerprint_match = subPolicy[range]
        guard fingerprint_match == expectedFingerprint.hexString else { throw WalletComposerError.invalidKey }
        return .pk
    }
}
