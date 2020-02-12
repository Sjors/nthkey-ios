---
description: How to use NthKey for iOs with Bitcoin Core to send and receive Bitcoin in a multi-signature wallet setup.
image: /assets/ios_confirm.png
author:
  twitter: provoost
---
# nthKey Tutorial

[![Tutorial video](assets/youtube.png)](https://www.youtube.com/watch?v=1YgkAOY08iE)

Prerequisites:
* install NthKey via [TestFlight](https://testflight.apple.com/join/Y6cbJbEe)
* Understand the [limitations](/#known-limitations)
* learn how to compile Bitcoin Core from source ([macOS](https://github.com/bitcoin/bitcoin/blob/master/doc/build-osx.md), [Linux](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md), [Windows](https://github.com/bitcoin/bitcoin/blob/master/doc/build-windows.md))
* learn how to use [Github forks](https://help.github.com/en/github/using-git/adding-a-remote)

## Wallet setup

You will be using Bitcoin Core to generate receive addresses, and the NthKey app to
verify them. Similarly you'll use Bitcoin Core to compose transactions drafts,
which you can then sign in the app, and with your other (hardware) wallets.

The second key can either be the same app on a different iOs device, a ColdCard
or any hardware wallet with PSBT support and a compatible public key export format.

When practing on Testnet you can also use a device simulator, for iOs and/or
any hardware wallet.

### Bitcoin Core

Follow the instructions for compiling Bitcoin Core (see prerequisites above), try the master branch first.

We going to use a highly experimental branch of Bitcoin Core. Only use this with testnet!

[Bitcoin Core experimental branch](https://github.com/Sjors/bitcoin/pull/13).

In order to use the branch from this pull request:

```
git remote add sjors git@github.com:sjors/bitcoin.git
git fetch sjors
git checkout 2020/01/descriptor-and-psbt
```

Compile as usual and start Bitcoin QT. It's recommended to set `addresstype=bech32` in [bitcoin.conf](https://github.com/bitcoin/bitcoin/blob/master/share/examples/bitcoin.conf).

Do not use this branch with your mainnet wallet, and be very cautious when running
code from strangers on the internet!

```sh
src/qt/bitcoin-qt -testnet
```

Go to the "File" -> "Create Wallet..." menu and fill out the form as follows:

![createwallet](/assets/core_createwallet.png){:height="200pt"}

### Coldcard

For testnet you can use either a physical device or a [simulator](https://github.com/Coldcard/firmware).

In the example below `00000001` represents the master key [fingerprint](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers) of your iOs wallet and `00000002` that of your Coldcard.

We need to give the Coldcard the iOs keys, by pretending it's another Coldcard. Conversely we need to give the iOs device the Coldcard keys.

In NthKey go to the Settings tab -> "Export public key".

![Export Public Key](/assets/export_pubkey.png){:width="300pt"}

You can save it on iCloud Drive first, and then on a Mac drag it to an SD card. It'll be called  `ccxp-00000001.json` . On the Coldcard, go to "Setttings" -> "Multisig"  -> "Create Airgapped".

Create Airgapped           |  Number of signers
:-------------------------:|:-------------------------:
![](/assets/cc_create_airgapped.png){:height="400pt"} | ![](/assets/cc_n_signers.png){:height="400pt"}

The Coldcard will generate a multisig wallet between itself and iOs. Click OK to save it to the SD card in a format compatible with Electrum. If all goes well the new wallet appears in the menu as `CC-2-of-2`:

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

I haven't tested importing the above, but it's a good sanity check.

Now that ColdCard is aware of both keys, we need export the key from Coldcard and import that into iOs, so that it too becomes aware of both keys. On the Coldcard, go to "Setttings" -> "Multisig"  -> "Export XPUB". This will create a file  `ccxp-00000002.json`. In the iOs app go to Settings -> "Add cosigner". Select the newly created file.

Unless you want to add more cosigners, click on Create Wallet.

## Bitcoin Core

To import into Bitcoin Core, in the app go to Settings ->  "Export to Bitcoin Core". Save the text file to iCloud drive so you can open it on your Mac or download it from icloud.com. This file does not contain private keys, but it is privacy sensitive. At least delete it when you're done.

On your computer that runs Bitcoin Core, open the debug window via "Window" -> "Console" . Be sure to select your new wallet first. Then copy the command from the file:

```
importdescriptors "[{\"desc\": \"wsh(sortedmulti( ... active":true}]'
```

![](/assets/core_importdescriptors.png){:height="500pt"}

If you restart Bitcoin Core you need to load it again (File -> Open Wallet) and select it (top-right drop down).

## Deposit to wallet

In Bitcoin Core go to the Receive tab and click "Create new receiving address".

![](/assets/core_receive.png){:height="500pt"}

There is currently no way to verify this address on the Coldcard. Work in progress pull requests:
* [Colcard firmware #25](https://github.com/Coldcard/firmware/pull/25)
* [HWI #279](https://github.com/bitcoin-core/HWI/pull/279) (requires [HWI](https://github.com/bitcoin-core/HWI/pull/279) and connecting via USB)

To verify the address on iOs, go to the "Addresses" tab:

![](/assets/ios_addresses.png){:height="300pt"}

I recommend funding the default Bitcoin Core testnet wallet from a [faucet](https://www.google.com/search?q=bitcoin+testnet+faucet), and then send a small amount to the mutlisig wallet. That way you can try again if the coins are permanently lost.

## Spend from wallet

The first step is to create a draft transaction in Bitcoin Core and save the PSBT.

### Bitcoin Core draft

Go to the send screen and draft a transaction as usual. Instead of "Send"
you'll see a button Create Unsigned. This copies a PSBT to your clipboard and
lets you save it as a `.psbt` file.

![](/assets/core_create_unsigned.png){:height="500pt"}

### Coldcard

Save the PSBT file on an SD card and sign it on the Coldcard.

![](/assets/cc_sign.png){:height="300pt"}

### iOs

Open the PSBT, with the ColdCard signature, via the Sign tab:

![](/assets/ios_load_psbt.png){:height="300pt"}

Check the destination address:

![](/assets/ios_confirm.png){:height="300pt"}

## Bitcoin Core broadcast

In case you signed in parallel, use the [combinepsbt](https://bitcoincore.org/en/doc/0.19.0/rpc/rawtransactions/combinepsbt/) RPC method first. If you signed them sequentially you should be good to go.

Go to the "File" -> "Load PSBT..." menu and find the singed PSBT. If all went
well, Bitcoin Core will offer to broadcast the transaction:

![](/assets/core_send_psbt.png){:height="150pt"}

The transaction should appear in your wallet and eventually confirm.
