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
* alternatively you can receive, _but not yet spend_, coins with Electrum

## Wallet setup

You will be using Bitcoin Core or Electrum to generate receive addresses, and the
NthKey app to verify them. Similarly you'll use Bitcoin Core, or soon(tm) Electrum,
to compose transactions drafts, which you can then sign in the app, and with your other (hardware) wallets.

The second key can either be the same app on a different iOs device, a ColdCard
or any hardware wallet with PSBT support and a compatible public key export format.

When practing on Testnet you can also use a device simulator, for iOs and/or
any hardware wallet.

### Compile Bitcoin Core

Alternatively you can use Electrum, see the next section.

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


### Install Electrum

You can use [Electrum](https://electrum.org/) instead of Bitcoin Core, but note that _sending from Electrum isn't supported yet_ in NthKey. This is arguably easier to setup, but it comes with reduced privacy, unless you also [setup a server](https://en.bitcoin.it/wiki/Electrum#Server_software). [Electrum Personal Server](https://github.com/chris-belcher/electrum-personal-server) is a light-weight server ideally suited for this task. It in turn relies on Bitcoin Core, but it lets you install a regular release; no need to compile anything.

Electrum has not released their PSBT support yet, as of version 3.3.8. You can setup your wallet and receive coins with the downloaded version, but in order to spend coins you need to [run the development version](https://github.com/spesmilo/electrum#development-version).

Launch Electrum in Testnet mode, e.g. on macOS: `/Applications/Electrum.app/Contents/MacOS/Electrum --testnet`.

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

The Coldcard will generate a multisig wallet between itself and iOs. Click OK to save it to the SD card in a format compatible with Electrum. If all goes well the new wallet appears in the menu as `CC-2-of-2`.

Now that ColdCard is aware of both keys, we need export the key from Coldcard and import that into iOs, so that it too becomes aware of both keys. On the Coldcard, go to "Setttings" -> "Multisig"  -> "Export XPUB". This will create a file  `ccxp-00000002.json`. In the iOs app go to Settings -> "Add cosigner". Select the newly created file.

Unless you want to add more cosigners, click on Create Wallet.

## Bitcoin Core import

To import into Bitcoin Core, in the app go to Settings ->  "Export to Bitcoin Core". Save the text file to iCloud drive so you can open it on your Mac or download it from icloud.com. This file does not contain private keys, but it is privacy sensitive. At least delete it when you're done.

On your computer that runs Bitcoin Core, open the debug window via "Window" -> "Console" . Be sure to select your new wallet first. Then copy the command from the file:

```
importdescriptors "[{\"desc\": \"wsh(sortedmulti( ... active":true}]'
```

![](/assets/core_importdescriptors.png){:height="500pt"}

If you restart Bitcoin Core you need to load it again (File -> Open Wallet) and select it (top-right drop down).

## Electrum import

If you have a ColdCard, you can more easily import the wallet using their [Electrum plugin](https://github.com/spesmilo/electrum/tree/master/electrum/plugins/coldcard).

Create a new multi-signature wallet. Select the number of signers and required signatures.

![](/assets/electrum_setup_1.png){:height="300pt"}

For each cosigner, open the `ccxp-00000000.json` file generated above. Look for the `p2wsh` and copy-paste its value ("Vpub...", this is the master public key) into Electrum.

![](/assets/electrum_setup_2.png){:height="300pt"}

Skip the screen that echoes this master key.

If you see `tpub...` instead of `Vpub...` you can covert it [here](https://jlopp.github.io/xpub-converter/) (only safe with testnet).  

## Deposit to wallet

In Bitcoin Core go to the Receive tab and click "Create new receiving address".

![](/assets/core_receive.png){:height="500pt"}

Electrum similarly has a Receive tab.

There is currently no way to verify this address on the Coldcard. Work in progress pull requests:
* [Colcard firmware #25](https://github.com/Coldcard/firmware/pull/25)
* [HWI #279](https://github.com/bitcoin-core/HWI/pull/279) (requires [HWI](https://github.com/bitcoin-core/HWI/pull/279) and connecting via USB)

To verify the address on iOs, go to the "Addresses" tab:

![](/assets/ios_addresses.png){:height="300pt"}

I recommend funding the default Bitcoin Core testnet wallet from a [faucet](https://www.google.com/search?q=bitcoin+testnet+faucet), and then send a small amount to the mutlisig wallet. That way you can try again if the coins are permanently lost.

## Spend from wallet

The first step is to create a draft transaction in Bitcoin Core and save the PSBT.

### Bitcoin Core draft

Go to the send tab and draft a transaction as usual. Instead of "Send"
you'll see a button Create Unsigned. This copies a PSBT to your clipboard and
lets you save it as a `.psbt` file.

![](/assets/core_create_unsigned.png){:height="500pt"}

### Electrum draft

Go to the send tab and draft a transaction as usual. Click Pay and then Send. In the bottom left corner click Export, Export to File.

Unfortunately we can't sign the resulting PSBT yet, which requires either a change to NthKey or to Electrum. See [Electrum Issue #5955](https://github.com/spesmilo/electrum/issues/5955)

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
