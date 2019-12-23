//
//  Destination.swift
//  Destination
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

struct Destination : Identifiable, Equatable {
    public let description: String
    public let id: String
    public let isChange: Bool
    
    init(output: PSBTOutput, inputs: [PSBTInput]) {
        self.description = String(output.txOutput.amount) + " sats" + ": " + output.txOutput.address!.description
        self.id = output.id
        let (us, cosigners) = Signer.getSigners()
        let cosignerKeys = cosigners.map { (signer) -> HDKey in
            signer.hdKey
        }
        self.isChange = output.isChange(signer: us.hdKey, inputs: inputs, cosigners: cosignerKeys, threshold: 2)
    }
    
}
