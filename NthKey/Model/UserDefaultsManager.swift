//
//  UserDefaultsManager.swift
//  UserDefaultsManager
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

class UserDefaultsManager: ObservableObject {
    @Published var hasCosigners: Bool = UserDefaults.standard.array(forKey: "cosigners") != nil
    private var notificationSubscription: AnyCancellable?

    init() {
        notificationSubscription = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).sink { _ in
            self.hasCosigners = UserDefaults.standard.array(forKey: "cosigners") != nil
            self.objectWillChange.send()
         }
        
    }
    
}
