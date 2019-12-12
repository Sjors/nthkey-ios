//
//  MultisigTests.swift
//  MultisigTests
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import XCTest
@testable import Multisig
import LibWally

class MultisigTests: XCTestCase {
    
    var signer1: Signer?
    var signer2: Signer?

    override func setUp() {
        let master1 = "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
        let master2 = "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
        
        let ours = try! HDKey(master1)!.derive(BIP32Path("m/48'/0'/0'/2'/0")!)
        let theirs = try! HDKey(master2)!.derive(BIP32Path("m/48'/0'/0'/2'/0")!)
        MultisigAddress.receivePublicHDkeys = [ours, theirs]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeriveAddress() {
        let address = MultisigAddress(0, network: .mainnet)
        XCTAssertEqual(address.description, "bc1qlpsgumjm2dlcljqc96c38n6q74jtn88enkr3wrz0rtp9jp6war7s2h4lrs")
    }

}
