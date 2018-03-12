# Lottery Forum

## Deploying
There are three contracts to deploy:

- Token
- Forum
- Lottery

## How to run the tests

```
dapp update
ln -s . lib/zeppelin-solidity/src
echo src >> .git/modules/zeppelin-solidity/info/exclude
dapp test
```
