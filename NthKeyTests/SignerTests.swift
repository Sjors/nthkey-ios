//
//  SignerTests.swift
//  SignerTests
//
//  Created by Sjors Provoost on 05/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
import NthKey
import LibWally

class SignerTests: XCTestCase {
    let xpub = "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitialize() {
        let signer = Signer(fingerprint: Data("3442193e")!, derivation: BIP32Path("m/0'/1")!, hdKey: HDKey(xpub)!, name: "NthKey")
        XCTAssertEqual(signer.fingerprint.hexString, "3442193e")
        XCTAssertEqual(signer.derivation.description, "m/0h/1")
        XCTAssertEqual(signer.hdKey.description, xpub)
    }

    func testEncode() {
        let signer1 = Signer(fingerprint: Data("3442193e")!, derivation: BIP32Path("m/0'/1")!, hdKey: HDKey(xpub)!, name: "NthKey")
        let encoded = try! NSKeyedArchiver.archivedData(withRootObject: signer1, requiringSecureCoding: true)
        let signer2 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encoded)!
        
        XCTAssertEqual(signer1.fingerprint, signer2.fingerprint)
        XCTAssertEqual(signer1.derivation.description, signer2.derivation.description)
        XCTAssertEqual(signer1.hdKey.xpub, signer2.hdKey.xpub)
    }

}
