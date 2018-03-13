# Lottery Forum

## Deploying
There are two contracts to deploy:

- Forum
- Lottery

After creating these contracts, call `Forum.setBeneficiary(Lottery)` to link the forum with its payout system.

## How to run the tests

```
dapp update
dapp test
```
