//
//  PSBTManager.swift
//  PSBTManager
//
//  Created by Sjors Provoost on 23/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

struct PSBTManager {
    var psbt: PSBT? = nil
    var signed: Bool = false
    var fee: String = ""
    var canSign: Bool = false
    var destinations: [Destination]?
    
    mutating func clear() {
        self.psbt = nil
        self.signed = false
        self.fee = ""
    }
    
    mutating func processPSBT(_ psbt: PSBT) {
        self.psbt = psbt
        self.destinations = psbt.outputs.map { output in
            return Destination(output: output, inputs: psbt.inputs)
        }
        if let fee = psbt.fee {
            self.fee = "\(fee) sats"
        }
        self.canSign = false
        let (us, _) = Signer.getSigners()
        for input in psbt.inputs {
            self.canSign = self.canSign || input.canSign(us.hdKey) as Bool
        }
        self.signed = false
    }

    
    mutating func loadPSBT(_ psbt: String) {
        if let psbt = try? PSBT(psbt, .testnet) {
            processPSBT(psbt)
        }
    }
    
    mutating func loadPSBT(_ data: Data) {
        if let psbt = try? PSBT(data, .testnet) {
            processPSBT(psbt)
       } else {
           NSLog("Something went wrong parsing PSBT data")
       }
    }
    
    mutating func open(_ url: URL) {
        let payload: Data
        do {
           payload = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
        } catch {
           NSLog("Something went wrong parsing PSBT file")
           return
        }
        loadPSBT(payload)
    }
}
