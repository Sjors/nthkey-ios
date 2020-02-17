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
        {"announcements":{"3442193e":{"can_decompile_miniscript":false,"keys":{"wsh":{"change":"[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/1\/*","receive":"[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/0\/*"}},"name":"NthKey","sub_policy":"pk(3442193e)"}}}
        """#
        let composer = WalletComposer(us: us!, signers: [us!])
        XCTAssertNotNil(composer)
        if (composer != nil) {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let encoded = try! encoder.encode(composer)
            let json = String(data: encoded, encoding: .utf8)!
            XCTAssertEqual(json, expected)
        }
    }
    
    func testParse() {
        let composer = #"""
        {"announcements":{"3442193e":{"can_decompile_miniscript":false,"name":"NthKey"}}}
        """#
        let jsonData = composer.data(using: .utf8)!
        let wallet = try! JSONDecoder().decode(WalletComposer.self, from: jsonData)

        XCTAssertEqual(wallet.announcements.count, 1)
    }
    
    func testParseFingerprint() {
        let composerMalformed = #"""
        {"announcements":{"344219":{"can_decompile_miniscript":false,"name":"NthKey"}}}
        """#
        let jsonData = composerMalformed.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(WalletComposer.self, from: jsonData))
    }
    
    func testAnnounceOtherKeys() {
        let expected = #"""
        {"announcements":{"3442193e":{"can_decompile_miniscript":false,"keys":{"wsh":{"change":"[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/1\/*","receive":"[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/0\/*"}},"name":"NthKey","sub_policy":"pk(3442193e)"},"bd16bee5":{"keys":{"wsh":{"change":"[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/1\/*","receive":"[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/0\/*"}},"name":"","sub_policy":"pk(bd16bee5)"}}}
        """#
        let composer = WalletComposer(us: us!, signers: [us!, cosigner1!])
        XCTAssertNotNil(composer)
        if (composer != nil) {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let encoded = try! encoder.encode(composer)
            let json = String(data: encoded, encoding: .utf8)!
            XCTAssertEqual(json, expected)
        }
    }
    
    func testAnnounceWalletPolicy() {
        let expected = #"""
         {"announcements":{"3442193e":{"can_decompile_miniscript":false,"keys":{"wsh":{"change":"[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/1\/*","receive":"[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/0\/*"}},"name":"NthKey","sub_policy":"pk(3442193e)"},"bd16bee5":{"keys":{"wsh":{"change":"[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/1\/*","receive":"[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/0\/*"}},"name":"","sub_policy":"pk(bd16bee5)"}},"descriptors":{"wsh":{"change":"wsh(sortedmulti(2,[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/1\/*,[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/1\/*))#8837llds","receive":"wsh(sortedmulti(2,[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/0\/*,[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/0\/*))#75z63vc9"}},"policy":"thresh(2,pk(3442193e),pk(bd16bee5))"}
         """#
         let composer = WalletComposer(us: us!, signers: [us!, cosigner1!], threshold: 2)
         XCTAssertNotNil(composer)
         if (composer != nil) {
             let encoder = JSONEncoder()
             encoder.outputFormatting = .sortedKeys
             let encoded = try! encoder.encode(composer)
             let json = String(data: encoded, encoding: .utf8)!
             XCTAssertEqual(json, expected)
         }
    }

}
