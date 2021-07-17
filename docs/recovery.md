# nthKey Wallet Recovery

*Updated July 17, 2021*

You must store the 24 word mnemonic in order to recover funds (in case your iOs
  device is lost or broken). But that is not sufficient for a multisig wallet
  _even if you set the threshold to 1_. In order to spend funds from your wallet
  you need the public key information from _all_ devices. Additionally you need
  to know the exact setup used to combine them.

The easiest way to store this information is to use the PDF backup feature of Specter.
If you keep that, along with the mnemonic(s) of _threshold_ devices, recovery
should be smooth.

Recovering your nthKey wallet involves two steps:

1. (re)install the app and enter the 24 words
2. import the wallet from Specter (scan the QR code on the backup paper)

For help recovering your other devices, see [walletsrecovery.org](https://walletsrecovery.org).

In case you're using another tool, and for posterity: the [BIP 88](https://github.com/bitcoin/bips/blob/master/bip-0088.mediawiki) derivation path template used
is `m/48'/0'/0'/2'/{0-1}/*`. Public keys for each index are sorted lexicographically (see [BIP 67](https://github.com/bitcoin/bips/blob/master/bip-0067.mediawiki)). This is based on the informal [m/48'](https://hackmd.io/@ChristopherA/B1jW4ghOU)
multisig standard. We will likely switch to [BIP 87](https://github.com/bitcoin/bips/blob/master/bip-0087.mediawiki)
for future wallets. The Specter PDF backup includes these derivation paths.  
