//
//  BitcoinCoreImportTests.swift
//  BitcoinCoreImportTests
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
import NthKey
import LibWally

class BitcoinCoreImportTests: XCTestCase {
    
    var signer1: Signer?
    var signer2: Signer?

    override func setUp() {
        let master1 = "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
        let master2 = "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
        
        let path = BIP32Path("m/48'/0'/0'/2'")!
        let multisigKey1 = try! HDKey(master1)!.derive(path)
        let multisigKey2 = try! HDKey(master2)!.derive(path)
    
        signer1 = Signer(fingerprint: Data("3442193e")!, derivation: path, hdKey: multisigKey1, name: "NthKey")
        signer2 = Signer(fingerprint: Data("bd16bee5")!, derivation: path, hdKey: multisigKey2, name:"")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImportMultiRPC() {
        let expected = #"""
        importdescriptors '[{"range":1000,"timestamp":"now","watchonly":true,"internal":false,"desc":"wsh(sortedmulti(2,[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/0\/*,[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/0\/*))#75z63vc9","active":true},{"range":1000,"timestamp":"now","watchonly":true,"internal":true,"desc":"wsh(sortedmulti(2,[3442193e\/48h\/0h\/0h\/2h]xpub6E64WfdQwBGz85XhbZryr9gUGUPBgoSu5WV6tJWpzAvgAmpVpdPHkT3XYm9R5J6MeWzvLQoz4q845taC9Q28XutbptxAmg7q8QPkjvTL4oi\/1\/*,[bd16bee5\/48h\/0h\/0h\/2h]xpub6DwQ4gBCmJZM3TaKogP41tpjuEwnMH2nWEi3PFev37LfsWPvjZrh1GfAG8xvoDYMPWGKG1oBPMCfKpkVbJtUHRaqRdCb6X6o1e9PQTVK88a\/1\/*))#8837llds","active":true}]'
        """#
        let importData = BitcoinCoreImport([signer1!, signer2!], threshold: 2)
        XCTAssertNotNil(importData)
        if (importData != nil) {
            let json: String = importData!.importDescriptorsRPC
            XCTAssertEqual(json, expected)
        }
    }

}
