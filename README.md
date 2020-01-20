# Nth Key for iOs [![Build Status](https://travis-ci.org/Sjors/nthkey-ios.svg?branch=master)](https://travis-ci.org/Sjors/nthkey-ios)

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

To preview documentation:

```sh
bundle exec jekyll server --incremental --source docs
```

To get the simulator working directory, export your public key in Settings. The path is printed in the log.  

## Usage

Install from [TestFlight](https://testflight.apple.com/join/Y6cbJbEe) and follow the [tutorial](https://nthkey.com/tutorial).

## Known issues
