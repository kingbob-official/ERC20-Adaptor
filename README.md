# ERC20-Adaptor
A proxy contract for ERC20 based DeFi to use EER2 function
## Installing / Getting started
You can compile and deploy this contract on [remix](https://remix.ethereum.org/#optimize=false&evmVersion=null)
## Developing
### Build With
- [Solidity](https://solidity.readthedocs.io/en/v0.5.0/index.html#)
- [Node js](https://nodejs.org/en/docs/)
- [ERC-20](https://eips.ethereum.org/EIPS/eip-20)
### Prerequisites
- Knowledge of EER-2 (Evrynet Enhancement Request) [here](https://github.com/evrynetlabs/credit-contract)
- Truffle [here](https://www.trufflesuite.com/docs/truffle/getting-started/installation)
- NPM [here](https://www.npmjs.com/)
- Yarn [here](https://yarnpkg.com/)
### Setting up Dev
```
$ yarn install
$ npm install -g truffle 
$ npm install solc@0.5.0 
```
### Building
Generate `truffle-config.js` first with run,
```
$ truffle init
````

And build the contract
```
$ truffle build
```

## Versioning
> `1.0.0`
## Specification
### Notes:
- The following specifications use syntax from Solidity 0.5.0 (or above)

### ERC20Adapter
This set of functions are all related to the [ERC20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)

### ERC20AdaptorFactory
> `function deployAdaptor(uint256 _creditTypeID) public returns (address)`


Returns the ERC20Adapter address whch binds with credit type id

## Test
Run `truffle test` to run the unit tests.

## Style guide
Using solhint for coding style . Please see configuration on `solhint.json`

## Licensing
ERC20 Adapter is licensed under the OSL Open Software License v3.0, also included in our repository in the LICENSE file.