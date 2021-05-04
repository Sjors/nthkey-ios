//
//  NoSeedView.swift
//  NoSeedView
//
//  Created by Fathi on 25/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct NoSeedView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var enterMnemonnic = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Your keys").font(.headline)
            Text("The app generates a fresh cryptographic key for you, or you can recover from a backup by entering its 24 words.")

            Button("Generate fresh keys") {
                SeedManager.generateSeed()
            }
            .disabled(self.enterMnemonnic)

            Button("Recover from backup") {
                self.enterMnemonnic.toggle()
            }

            if self.enterMnemonnic {
                EnterMnenonicView(model: EnterMnenonicViewModel())
                    .environmentObject(self.appState)
            }
        }
    }
}

#if DEBUG
struct NoSeedView_Previews: PreviewProvider {
    static var previews: some View {
        let view = NoSeedView()

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
