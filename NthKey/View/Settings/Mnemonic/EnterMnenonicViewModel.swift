//
//  EnterMnenonicViewModel.swift
//  EnterMnenonicViewModel
//
//  Created by Sergey Vinogradov on 02.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine
import LibWally

final class EnterMnenonicViewModel: ObservableObject {
    @Published var validMnemonic: Bool = false
    @Published var mnemonicText: String = ""
    @Published var currentWord: String = ""
    @Published var suggestions: [String] = []

    private var cancellables = Set<AnyCancellable>()

    private let words: [String]

    init() {
        if let filepath = Bundle.main.path(forResource: "english", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                words = contents.components(separatedBy: "\n").filter { !$0.isEmpty }
            } catch {
                words = []
            }
        } else {
            words = []
        }

        setupObservables()
    }

    func applyEntropy() {
        let words: [String] = self.mnemonicText.components(separatedBy: " ")
        SeedManager.setEntropy(LibWally.BIP39Mnemonic(words)!.entropy)
    }

    func changeCurrentStringWith(_ text: String) {
        mnemonicText = mnemonicText.replacingOccurrences(of: currentWord, with: text)
        suggestions.removeAll()
    }

    // MARK: - Private

    private func setupObservables() {
        $mnemonicText
            .dropFirst()
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }

                let words = text.components(separatedBy: " ")
                self.validateMnemonic(words: words)

                guard let last =  words.last(where: { !$0.isEmpty }) else { return }
                self.currentWord = last
            }
            .store(in: &cancellables)

        $currentWord
            .dropFirst()
            .sink{ [weak self] value in
                guard let self = self,
                      !value.isEmpty else { return }
                self.suggestions = self.words.filter { $0.hasPrefix(value) }
            }
            .store(in: &cancellables)
    }

    private func validateMnemonic(words: [String]) {
        // TODO:
        // * check every word against BIP39Words
        // * suggest autocomplete for each
        if words.count == 12 || words.count == 16 || words.count == 24 {
            // TODO:
            // * make BIP39Mnemonic do the above check
            // * make isValid public
            self.validMnemonic = LibWally.BIP39Mnemonic(words) != nil
        } else {
            self.validMnemonic = false
        }
    }
}
