# Multisig iOs

Use your iOs device as part of a Bitcoin multi-signature setup.

Uses [LibWally](https://github.com/ElementsProject/libwally-core) via a
[Swift wrapper](https://github.com/blockchain/libwally-swift).

## Build

Install dependencies:

```sh
brew install gnu-sed
```

Install Ruby, e.g. using [RBenv](https://github.com/rbenv/rbenv) and Cocoapods:

```sh
rbenv install `cat .ruby-version`
gem install cocoapods
pod install --verbose
```

## Wallet setup

You will be using Bitcoin Core to generate receive addresses, and this app to
verify them. Similarly you'll use Bitcoin Core to compose transactions drafts,
which you can then sign with this app.

The second key can either be the same app on a different iOs device, a ColdCard
or any hardware wallet with PSBT support and a compatible public key export format.

### Bitcoin Core

Follow the instructions for compiling Bitcoin Core, try the master branch first.
* https://github.com/bitcoin/bitcoin/blob/master/doc/build-osx.md (macOS)
* https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md (Linux)

We use a highly experimental branch of Bitcoin Core. Only use this with testnet!

https://github.com/bitcoin/bitcoin/pull/16528

In order to use the branch from this pull request:

```
git remote add achow101 git@github.com:achow101/bitcoin.git
git fetch achow101
git checkout achow101/wallet-of-the-glorious-future
```

Then compile as usual. It's recommended to set `addresstype=bech32` in `bitcoin.conf`.

Create a new wallet:

```
src/bitcoin-cli -testnet createwallet iOsMulti true true "" true true
```

### Coldcard

For testnet you can use either a physical device or a simulator: https://github.com/Coldcard/firmware

In the example below `00000001` represents the master key fingerprint of your iOs wallet and `00000002` that of your Coldcard.

We need to give the Coldcard the iOs keys, by pretending it's another Coldcard. Conversely we need to give the iOs device the Coldcard keys.

In the app, go to the Settings tab -> "Export public key". You can save it on iCloud Drive first, and then on a Mac drag it to an SD card. It'll be called  `ccxp-00000001.json` . On the Coldcard, go to "Setttings" -> "Multisig"  -> "Create Airgapped". The Coldcard will generate a multisig wallet between itself and iOs. It should show up as `CC-2-of-2`. Select it and click on "Electrum Wallet". This saves the wallet information we need to the SD card in a format compatible with Electrum (I haven't tested this):

```
# Coldcard Multisig setup file (created on 00000002)
#
Name: CC-2-of-2
Policy: 2 of 2
Derivation: m/48'/1'/0'/2'
Format: P2WSH

00000002: tpub...
00000001: tpub...
```

Now let's export the key from Coldcard and import that into iOs. On the Coldcard, go to "Setttings" -> "Multisig"  -> "Export XPUB". This will create a file  `ccxp-00000002.json`. In the iOs app go to Settings -> "Add cosigner". Select the newly created file.

## Bitcoin Core

To import into Bitcoin Core, in the app go to Settings ->  "Export to Bitcoin Core". Save the text file to iCloud drive so you can open it on your Mac or download it from icloud.com. This file does not contain private keys, but it is privacy sensitive. At least delete it when you're done.

On your computer that runs Bitcoin Core, open the file and copy the command in it:

```
src/bitcoin-cli -testnet -rpcwallet=iOsMulti importdescriptors "[{\"desc\": \"wsh(sortedmulti( ... active":true}]'
```

This will complain that the [descriptor](https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md) has an incorrect checksum `#00000000`. Because this is testnet, just copy the correct checksums from the error message and try again.

## Deposit to wallet

Warning: there is no spending code yet, so unless you set the multisig threshold to 1, these coins will be locked.

```
src/bitcoin-cli -testnet -rpcwallet=iOsMulti generatenewaddress "" bech32
```

Or use Bitoin QT, load the wallet (File -> Open Wallet) and select it (top-right drop down), go to the Receive tab and click "Create new receiving address".

There is currently no way to verify this address on the Coldcard. Work in progress pull requests:
* https://github.com/Coldcard/firmware/pull/25
* https://github.com/bitcoin-core/HWI/pull/279 (requires [HWI](https://github.com/bitcoin-core/HWI/pull/279) and connecting via USB)

To verify the address on iOs, go to the "Addresses" tab.

I recommend funding the default Bitcoin Core testnet wallet from a faucet, and then send a small amount to the mutlisig wallet. That way you can try again if the coins are permanently lost.

## Spend from wallet

Warning:  there is no spending code yet. The instructions here only cover the other multisig participants.

The first step is to create a draft transaction in Bitcoin and save the PSBT.

## Bitcoin Core draft

Go to the send screen and draft a transaction as usual. Instead of "Send"
you'll see a button Create Unsigned. This copies a PSBT to your clipboard.

Copy the "psbt" part of the result. You'll need this in the next steps.

### iOs

TODO

### Coldcard

With the PSBT copied from Bitcoin Core:

```
echo "cH...A=" | base64 --decode --output tx.psbt
```

Put this on the SD card and sign it on the Coldcard.

You can inspect the partially signed PSBT:

```
src/bitcoin-cli -testnet "`base64 --input tx-part.psbt`"
```

## Bitcoin Core combine and broadcast

TODO

### GUI future

There is work in progress to allow creating, saving and load PSBTs from the GUI:

* https://github.com/bitcoin/bitcoin/pull/17509
* https://github.com/bitcoin/bitcoin/issues/17619

Once that's in place, the GUI workflow will be to create a transaction as usual, but to click "Save PSBT" instead of "Send", save it on the SD card, sign with ColdCard and load it again with Bitcoin Core. Similarly and in parallel, once the app supports it, you would sign it there and load / copy the result back into Bitcoin Core. Once all signatures are found, it would combine them and broadcast the transaction.

## Known issues
