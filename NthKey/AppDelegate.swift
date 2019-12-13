//
//  AppDelegate.swift
//  Nth Key
//
//  Created by Sjors Provoost on 26/11/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md
//

import UIKit
import CoreData
import LibWally

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var masterKey: HDKey
        
        let defaults = UserDefaults.standard
        
        if let fingerprint = defaults.data(forKey: "masterKeyFingerprint") {
            let entropyItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: fingerprint, accessGroup: nil)

            // Uncomment to reset
//             defaults.removeObject(forKey: "masterKeyFingerprint")
//             try! entropyItem.deleteItem()
//             return false

            // TODO: handle error
            let entropy = try! entropyItem.readEntropy()
            let mnemonic = BIP39Mnemonic(entropy)!
            let seedHex = mnemonic.seedHex()
            masterKey = HDKey(seedHex, .testnet)!
            assert(masterKey.fingerprint == fingerprint)
            // Uncomment to print mnemonic for backup (obviously unsafe)
//            NSLog("%@", mnemonic.description)
        } else {
            var bytes = [Int8](repeating: 0, count: 32)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            let entropy = BIP39Entropy(Data(bytes: bytes, count: bytes.count))
            let seedHex = BIP39Mnemonic(entropy)!.seedHex()
            masterKey = HDKey(seedHex, .testnet)!

            if status == errSecSuccess { // Always test the status.
                let seedItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: masterKey.fingerprint, accessGroup: nil)
                // TODO: handle error
                try! seedItem.saveEntropy(entropy)
                defaults.set(masterKey.fingerprint, forKey: "masterKeyFingerprint")
            }
            
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "NthKey")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

