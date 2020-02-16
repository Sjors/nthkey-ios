//
//  WalletComposerTests.swift
//  WalletComposerTests
//
//  Created by Sjors Provoost on 16/02/2020.
//  Copyright © 2020 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
import NthKey
import LibWally

class WalletComposerTests: XCTestCase {
    var us: Signer?
    var cosigner1: Signer?

    override func setUp() {
        let master1 = "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
        let master2 = "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
        
        let path = BIP32Path("m/48'/0'/0'/2'")!
        let multisigKey1 = try! HDKey(master1)!.derive(path)
        let multisigKey2 = try! HDKey(master2)!.derive(path)
    
        us = Signer(fingerprint: Data("3442193e")!, derivation: path, hdKey: multisigKey1, name: "NthKey")
        cosigner1 = Signer(fingerprint: Data("bd16bee5")!, derivation: path, hdKey: multisigKey2, name:"")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAnnounceOurKey() {
        let expected = #"""
        {"announcements":[{"fingerprint":"3442193e","name":"NthKey"}]}
        """#
        let composer = WalletComposer(us: us!, signers: [us!])
        XCTAssertNotNil(composer)
        if (composer != nil) {
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(composer)
            let json = String(data: encoded, encoding: .utf8)!
            XCTAssertEqual(json, expected)
        }
    }
    
    func testAnnounceOtherKeys() {
        let expected = #"""
        {"announcements":[{"fingerprint":"3442193e","name":"NthKey"},{"fingerprint":"bd16bee5","name":""}]}
        """#
        let composer = WalletComposer(us: us!, signers: [us!, cosigner1!])
        XCTAssertNotNil(composer)
        if (composer != nil) {
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(composer)
            let json = String(data: encoded, encoding: .utf8)!
            XCTAssertEqual(json, expected)
        }
    }

}
