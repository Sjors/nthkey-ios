//
//  PersistentStore.swift
//  PersistentStore
//
//  Created by Sergey Vinogradov on 08/03/2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import CoreData
import LibWally

struct PersistentStore {
    static var preview: PersistentStore = {
        let result = PersistentStore(inMemory: true)
        let viewContext = result.container.viewContext

        // wallet
        let wallets: [WalletEntity] = [WalletEntity(context: viewContext), WalletEntity(context: viewContext)]
        var first = true
        for wallet in wallets {
            wallet.label = "\(first ? "A" : "") Testnet wallet"
            wallet.network = Int16(Network.testnet.rawValue)
            wallet.receive_descriptor = UUID().uuidString
            wallet.threshold = 0

            first = false
        }

        // co-signers
        let cosigner = CosignerEntity(context: viewContext)
        cosigner.derivation = ""
        cosigner.fingerprint = Data("bd16bee5")
        cosigner.name = "Ourself"
        cosigner.xpub = ""

        for wallet in wallets {
            wallet.addToCosigners(cosigner)
        }

        /// Codes from the test net for mockup
        let codes = [["tb1qlpsgumjm2dlcljqc96c38n6q74jtn88enkr3wrz0rtp9jp6war7salrsel",
                      "tb1qwnhft38pv94t42wxna0tvcph44zdg2uttf05vm6l9cf6uw0xfkwqtz3hcl",
                      "tb1qy2zvrtllm32g63qntl22x4nar5ryp9leezve03yl399hmhz2dfjqtyy5zv",
                      "tb1quxgy3qp5l3uelm5s6q2fjzfkdrf92fl5twxxlnsa99svdrtv6m4s93pl2k",
                      "tb1q7f9ql7tt588kk9l4h0h8alqpgv8u8v8jl8mrn5wsfqxx3mg7f9nqv2qkkg",
                      "tb1qqg2qah02myrxuekexfuuqpd5wh7nse3hhj93mpp202fr734em7nssed0na",
                      "tb1qnvhud72jza2ghyt94vdsjwv9cxa3jklcsemn8lvagyxqsy8935gseeaqrh",
                      "tb1q4dqxc9jkntd5ddh5kps7y7627085wzju4x6my6mfrq7knr238zzquga3te",
                      "tb1qawe50gwz3atuljl60az0zhtztv27ptvklumjnrkclmhkk44jzkpsuzy39n",
                      "tb1qdwqj9mhgz9z074atas8zfdke4dfskezhne3604738cqzql6l669swyujes"],
                     ["tb1qjys5d3xt23aap5c9ty9uuhqld6xp7699hcj2rsu9mtygctxx64uqruqfsu",
                      "tb1qzvl6ruxqm62zwgnmu2u88unc6uja3s4mln4pghrw0qg24696jjysa6ack3",
                      "tb1qp7g9vt3pjlmve7dg0rnchacastxxnddhysd20pwlsdswvgc62qgspmns4w",
                      "tb1qn9hpm3rqsxvgksa2y977xxtqnflwdq0ejsjnmdyvzd9k9v9d0dpsk77jka",
                      "tb1qvddnv6rz557mfwep3tg7dgp55fdahyxwmwcaqp0kq38da8q69yqqaxzd0n",
                      "tb1qwf8k7yshdfdan6w52e3xdj6syvqn6xts0xr4ew27xst7kemqd89qhdvawg",
                      "tb1qllv3xtjfwcvqfe6etl36ppva39cz3t3zuk2qr0j4t3pkx9hksacsjrn96y",
                      "tb1qxj9jm442vnww9eq6pwz2093ky6feekkk2afgqlnu3m7exxrawvcsll0trp",
                      "tb1qlv6luhftea629fw3g94vxrzv7996pudqat9u46mwmd5mvqd5l2esdv5d3v",
                      "tb1qva6alax92j5ul7anfcvzf26722zvyxd9gw2m3zfz20w0z7rp7hnq62ay95"]]
        var used = 3
        for widx in 0..<codes.count {
            for idx in 0..<codes[widx].count {
                let item = AddressEntity(context: viewContext)
                item.receiveIndex = Int32(idx)
                item.address = codes[widx][idx]

                if used > 0 {
                    used -= 1
                    item.used = true
                }

                wallets[widx].addToAddresses(item)
            }
            used = 2
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
