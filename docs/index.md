---
description: Your iOs device in a Bitcoin multi-sig
image: /assets/ios_confirm.png
---
# Your iOs device in a Bitcoin multi-sig

Just download nthKey from the [App Store](https://apps.apple.com/us/app/nthkey/id1491367033) and follow the [tutorial](tutorial). You can try it for free and without risk using valueless testnet and signet coins from a faucet. Then upgrade to a mainnet subscription if you like it.

## Use with Bitcoin Core and Specter

This is not a wallet, only a key manager. You'll use [Bitcoin Core](https://bitcoincore.org/en/download/) to download and verify the blockchain, track your wallet balance, craft a transaction, estimate the perfect fee and broadcast it to the network once you've signed.

Because some of this functionality is a bit tedious in Bitcoin Core, we recommend using the [Specter Desktop](https://github.com/cryptoadvance/specter-desktop#specter-desktop) application to make the entire process straight forward. The [tutorial](tutorial) will guide you through it.

## Verify receive addresses

After you create a receive address in Bitcoin Core or in Specter, you can verify it on the device. That way you can make sure no malware[^malware] on your computer has been messing with it.

![](/assets/ios_addresses.png){:height="300pt"}

[^malware]: don't push your luck though, malware can fool you in countless ways

## Check transaction before you sign

![](/assets/ios_confirm.png){:height="300pt"}

## Combine multiple devices

### Setup your multisig wallet

To get started, the app displays a QR code with your public keys. Using Specter
or your favorite tool of choice, you simply scan it and configure your multisig wallet.
Once configured, scan the resulting QR code with the app and you're all set.

![](/assets/export_pubkey.png){:width="300pt"}

### Multiple NthKey apps

You can run the app on different iOs devices, each with its own[^trust] private keys.

[^trust]: this requires a reckless degree of trust in both the app and Apple though; always use it in combination with a different (hardware) wallet / key manager.

### Other hardware wallets

The Specter desktop app supports many different hardware wallets. You can even
import your nThKey recovery phrase into a different hardware wallet.

## Source code

* iOs app: [github.com/Sjors/nthkey-ios](https://github.com/Sjors/nthkey-ios/)
* LibWally Swift: [github.com/Sjors/libwally-swift](https://github.com/Sjors/libwally-swift)
* LibWally Core: [github.com/ElementsProject/libwally-core](https://github.com/ElementsProject/libwally-core)
* Output Descriptors for Swift: [github.com/sjors/output-descriptors-swift](https://github.com/sjors/output-descriptors-swift)

## Contact

* [support@nthkey.com](mailto:support@nthkey.com) ([PGP](/assets/D4A570A5.asc))
* [sjors@sprovoost.nl](mailto:sjors@sprovoost.nl) ([PGP](/assets/CC301009.asc))

{% include social.html %}
