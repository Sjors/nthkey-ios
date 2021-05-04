//
//  NoSeedView.swift
//  NoSeedView
//
//  Created by Fathi on 25/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct NoSeedView: View {
    @Binding var hasSeed: Bool
    
    @State private var enterMnemonnic = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Your keys")
                .font(.headline)
            Text("The app generates a fresh cryptographic key for you, or you can recover from a backup by entering its 24 words.")

            Button("Generate fresh keys") {
                SeedManager.generateSeed()
                hasSeed = true
            }
            .disabled(enterMnemonnic)

            Button("Recover from backup") {
                enterMnemonnic.toggle()
            }

            if self.enterMnemonnic {
                EnterMnenonicView(model: EnterMnenonicViewModel(),
                                  hasSeed: $hasSeed)
            }
        }
    }
}

#if DEBUG
struct NoSeedView_Previews: PreviewProvider {
    static var previews: some View {
        let view = NoSeedView(hasSeed: .constant(false))

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
