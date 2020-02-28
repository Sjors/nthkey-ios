//
//   Nth KeyTests.swift
//   Nth KeyTests
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import XCTest
@testable import NthKey
import LibWally
class NthKeyTests: XCTestCase {
    
    var signer1: Signer?
    var signer2: Signer?

    override func setUp() {
        let outMasterKey = "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
        let theirXpub = "xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a"
        let theirFingerprint = Data("bd16bee5")!
        
        let ours = try! HDKey(outMasterKey)!.derive(BIP32Path("m/48'/0'/0'/2'/0")!)
        let theirs = HDKey(theirXpub, masterKeyFingerprint:theirFingerprint)!
        let theirReceiveHDKey = try! theirs.derive(BIP32Path(0))
        MultisigAddress.receivePublicHDkeys = [ours, theirReceiveHDKey]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeriveAddress() {
        let address = MultisigAddress(threshold: 2, receiveIndex: 0, network: .mainnet)
        XCTAssertEqual(address.description, "bc1qlpsgumjm2dlcljqc96c38n6q74jtn88enkr3wrz0rtp9jp6war7s2h4lrs")
    }

}
