# Lottery Forum

## Deploying
There are three contracts to deploy:

- Token (menlo-token-crowdsale)
- Forum
- Lottery

After creating these contracts, call `Forum.setBeneficiary(Lottery)` to link the forum with its payout system.
Then, two of the Token's board members  must `install` the Lottery to allow `appTransfer`.

## How to run the tests

```
dapp update
ln -s . lib/zeppelin-solidity/src
echo src >> .git/modules/zeppelin-solidity/info/exclude
dapp test
```
