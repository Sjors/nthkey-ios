//
//  PersistentStore.swift
//  PersistentStore
//
//  Created by Sergey Vinogradov on 08/03/2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import CoreData

struct PersistentStore {
    static var preview: PersistentStore = {
        let result = PersistentStore(inMemory: true)
        let viewContext = result.container.viewContext
        // wallet
        let wallet = WalletEntity(context: viewContext)
        let codes = [
            "bc1qlpsgumjm2dlcljqc96c38n6q74jtn88enkr3wrz0rtp9jp6war7s2h4lrs",
            "bc1qwnhft38pv94t42wxna0tvcph44zdg2uttf05vm6l9cf6uw0xfkwqu28czs",
            "bc1qy2zvrtllm32g63qntl22x4nar5ryp9leezve03yl399hmhz2dfjquvjmcr",
            "bc1quxgy3qp5l3uelm5s6q2fjzfkdrf92fl5twxxlnsa99svdrtv6m4sjehsse",
            "bc1q7f9ql7tt588kk9l4h0h8alqpgv8u8v8jl8mrn5wsfqxx3mg7f9nqmzkev8",
            "bc1qqg2qah02myrxuekexfuuqpd5wh7nse3hhj93mpp202fr734em7ns83mqfj",
            "bc1qnvhud72jza2ghyt94vdsjwv9cxa3jklcsemn8lvagyxqsy8935gsw3t0ec",
            "bc1q4dqxc9jkntd5ddh5kps7y7627085wzju4x6my6mfrq7knr238zzqtqt73k",
            "bc1qawe50gwz3atuljl60az0zhtztv27ptvklumjnrkclmhkk44jzkpst2j7lu",
            "bc1qdwqj9mhgz9z074atas8zfdke4dfskezhne3604738cqzql6l669sev2arl"]
        var used = 3
        for idx in 0..<codes.count {
            let item = AddressEntity(context: viewContext)
            item.wallet = wallet
            item.receiveIndex = Int16(idx)
            item.address = codes[idx]
            if used > 0 {
                used -= 1
                item.used = true
            }
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NthKey")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
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
    }
}
