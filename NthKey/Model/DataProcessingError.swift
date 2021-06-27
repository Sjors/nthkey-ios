//
//  DataProcessingError.swift
//  DataProcessingError
//
//  Created by Sergey Vinogradov on 13.06.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

enum DataProcessingError: Error, LocalizedError, Identifiable {
    var id: String { errorDescription ?? "" }

    // load wallet json
    case wrongInputData
    case duplicateWallet
    case unableParseDescriptor(String?)
    case wrongDescriptor
    case notEnoughKeys
    case wrongCosigner
    case wrongNumberOfCosigners
    case missedFingerprint
    case wrongNetwork

    // scan QR
    case wrongEncoding
    case badInputOutput
    case addressNotInList

    // PSBT
    case wrongPSBT

    public var errorDescription: String? {
        switch self {
        // load wallet json
        case .wrongInputData:
            return "JSON format not recognized"
        case .duplicateWallet:
            return "The wallet was imported before."
        case .unableParseDescriptor(let descriptor): //private ParseError not allow to share more info
            return "Unable to parse descriptor: \(descriptor ?? "N/A")"
        case .wrongDescriptor:
            return "Expected sortedmulti descriptor"
        case .notEnoughKeys:
            return "Require at least 2 keys"
        case .wrongCosigner:
            return "Malformated cosigner xpub"
        case .wrongNumberOfCosigners:
            return "Cosigner count does not match descriptor keys count"
        case .wrongNetwork:
            return "Received wallet's network isn't equal to selected one"

        // scan QR
        case .wrongEncoding:
            return "Data from QR has wrong encoding"
        case .badInputOutput:
            return "Can't recognize QR image"
        case .addressNotInList:
            return "Adress not in list"

        // PSBT
        case .wrongPSBT:
            return "Something went wrong parsing PSBT file"

        default:
            return nil
        }
    }
}
