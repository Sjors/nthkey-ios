//
//  WalletComposer.swift
//  WalletComposer
//
//  Created by Sjors Provoost on 16/02/2020.
//  Copyright © 2020 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

public struct WalletComposer : Codable {
    
    var announcements: [SignerAnnouncement]
    var policy: String?

    public struct SignerAnnouncement: Codable {
        private var fingerprint: Data
        var name: String
        var fingerprintString: String {
            get { return fingerprint.hexString }
        }

        private enum CodingKeys : String, CodingKey {
            case fingerprintString = "fingerprint"
            case name
        }
        
        init(fingerprint: Data, name: String) {
            self.fingerprint = fingerprint
            self.name = name
        }

        public init(from decoder:Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            let fingerprintString = try container.decode(String.self, forKey: .fingerprintString)

            if fingerprintString.count != 8 {
                throw DecodingError.dataCorruptedError(
                    forKey:.fingerprintString,
                    in: container,
                    debugDescription: """
                    Expected "\(fingerprintString)" to have 8 characters
                    """
                )
            }
    
            guard let value = Data(fingerprintString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .fingerprintString,
                    in: container,
                    debugDescription: """
                    Failed to convert an instance of \(Data.self) from "\(fingerprintString)"
                    """
                )
            }
            
            if value.hexString != fingerprintString {
                  throw DecodingError.dataCorruptedError(
                      forKey:.fingerprintString,
                      in: container,
                      debugDescription: """
                      "\(fingerprintString)" is not hex
                      """
                  )
            }

            fingerprint = value
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(fingerprintString, forKey: .fingerprintString)
            try container.encode(name, forKey: .name)
        }
    }
    
    public init?(us: Signer, signers: [Signer], threshold: Int? = nil) {
        self.announcements = signers.map { signer in
            return SignerAnnouncement(fingerprint: signer.fingerprint, name: us == signer ? "NthKey" : "")
        }
        if let threshold = threshold {
            self.policy = "thresh(\(threshold),\(signers.map { signer in "pk(\( signer.fingerprint.hexString ))" }.joined(separator:",") ))"
        }
    }
}
