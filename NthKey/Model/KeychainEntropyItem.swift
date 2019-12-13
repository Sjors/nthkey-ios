/*
    Copyright © 2016 Apple Inc. All Rights Reserved.
    Copyright © 2019 Purple Dunes. Distributed under the MIT software
    license, see the accompanying file LICENSE.md

    Abstract:
    A struct for accessing BIP39 entropy in the keychain. This entropy
    can be converted to a 12-24 word BIP39 mnemonic. Entries are identified
    by their master key fingerprint.
*/

import Foundation

import LibWally

struct KeychainEntropyItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noEntropy
        case entropyAlreadyExists
        case unexpectedEntropyData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Properties
    
    let service: String
    
    private(set) var fingerprint: Data
    
    let accessGroup: String?

    // MARK: Intialization
    
    init(service: String, fingerprint: Data, accessGroup: String? = nil) {
        self.service = service
        self.fingerprint = fingerprint
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    func readEntropy() throws -> BIP39Entropy  {
        /*
            Build a query to find the item that matches the service, fingerprint and
            access group.
        */
        var query = KeychainEntropyItem.keychainQuery(withService: service, fingerprint: fingerprint, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noEntropy }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the entropy hex string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let entropy = existingItem[kSecValueData as String] as? Data
        else {
            throw KeychainError.unexpectedEntropyData
        }
        
        return BIP39Entropy(entropy)
    }
    
    func saveEntropy(_ entropy: BIP39Entropy) throws {
        do {
            // Check for an existing item in the keychain.
            try _ = readEntropy()
            // Throw an error if entropy was already saved for this fingerprint; could indicate a collision
            throw KeychainError.entropyAlreadyExists
        }
        catch KeychainError.noEntropy {
            /*
                No entropy was found in the keychain. Create a dictionary to save
                as a new keychain item.
            */
            var newItem = KeychainEntropyItem.keychainQuery(withService: service, fingerprint: fingerprint, accessGroup: accessGroup)
            newItem[kSecValueData as String] = entropy.data as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainEntropyItem.keychainQuery(withService: service, fingerprint: fingerprint, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    static func entropyItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainEntropyItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainEntropyItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        // Create a `KeychainEntropyItem` for each dictionary in the query result.
        var entropyItems = [KeychainEntropyItem]()
        for result in resultData {
            guard let fingerprint = result[kSecAttrAccount as String] as? Data else { throw KeychainError.unexpectedItemData }
            
            let entropyItem = KeychainEntropyItem(service: service, fingerprint: fingerprint, accessGroup: accessGroup)
            entropyItems.append(entropyItem)
        }
        
        return entropyItems
    }

    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, fingerprint: Data? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let fingerprint = fingerprint {
            query[kSecAttrAccount as String] = fingerprint as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
