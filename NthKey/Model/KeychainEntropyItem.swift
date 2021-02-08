/*
 Copyright © 2016 Apple Inc. All Rights Reserved.
 Copyright © 2019 Purple Dunes. Distributed under the MIT software
 license, see the accompanying file LICENSE.md
 
 Abstract:
 A struct for accessing BIP39 entropy Data in the keychain. This entropy
 can be converted to a 12-24 word BIP39 mnemonic.
 */

import Foundation

struct KeychainEntropyItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noEntropy
        case entropyAlreadyExists
        case unexpectedEntropyData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Keychain access
    
    static func read(service: String, accessGroup: String? = nil) throws -> Data  {
        /*
         Build a query to find an "entropy" item (matching the service and
         access group)
         */
        var query = KeychainEntropyItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecAttrAccount as String] = "entropy" as AnyObject
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
        
        return entropy
    }
    
    static func save(entropy: Data, service: String, accessGroup: String? = nil) throws {
        do {
            // Check for an existing item in the keychain.
            try _ = KeychainEntropyItem.read(service: service, accessGroup: accessGroup)
            // Throw an error if entropy was already saved
            throw KeychainError.entropyAlreadyExists
        }
        catch KeychainError.noEntropy {
            /*
             No entropy was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = KeychainEntropyItem.keychainQuery(withService: service, accessGroup: accessGroup)
            newItem[kSecValueData as String] = entropy as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    static func delete(service: String, accessGroup: String? = nil) throws {
        // Delete the existing entropy item from the keychain.
        let query = KeychainEntropyItem.keychainQuery(withService: service, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        query[kSecAttrAccount as String] = "entropy" as AnyObject
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
