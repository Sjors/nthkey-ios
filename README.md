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
