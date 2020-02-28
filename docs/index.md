---
description: Your iOs device in a Bitcoin multi-sig
image: /assets/ios_confirm.png
---
# Your iOs device in a Bitcoin multi-sig

[Try it on TestFlight](https://testflight.apple.com/join/Y6cbJbEe) by following the [tutorial](tutorial).

## Use with Bitcoin Core

This is not a wallet, only a key manager. Use [Bitcoin Core](https://bitcoincore.org/en/download/) to download the blockchain, see your wallet balance, craft a transaction, estimate the perfect fee and broadcast it to the network once you've signed. It takes a little bit of effort to setup, but after that it's easy[^easy] to use. The [tutorial](tutorial) will guide you through it.

[^easy]: it should be easy by the time this hits the App Store :-)

## Verify receive addresses

After you create a receive address in Bitcoin Core, you can verify it on the device. That way you can make sure no malware[^malware] on your computer has been messing with it.

![](/assets/ios_addresses.png){:height="300pt"}

[^malware]: don't push your luck though, malware can fool you in countless ways

## Check transaction before you sign

![](/assets/ios_confirm.png){:height="300pt"}

## Combine multiple devices

### Export and import keys

![](/assets/export_pubkey.png){:width="300pt"}

### Multiple NthKey apps

You can run the app on different iOs devices, each with its own[^trust] private keys.

[^trust]: this requires a reckless degree of trust in both the app and Apple though; always use it in combination with a different (hardware) wallet / key manager.

### Coldcard

You can export your public keys to Coldcard and vice versa, to create a multisig wallet with it.

![](/assets/cc_create_airgapped.png){:height="400pt"}


### Other hardware wallets

Coming soon (tm)

## Known limitations

* Testnet only
* See [Github issues](https://github.com/Sjors/nthkey-ios/issues)

## Contact

[sjors@sprovoost.nl](mailto:sjors@sprovoost.nl) ([PGP](/assets/CC301009.asc))

{% include social.html %}
