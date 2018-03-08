# ERC *Draft* Specification
Mineable Token Specification

    EIP: <to be assigned>
    Title: Mineable Token Standard
    Author: Jay Logelin <jlogelin@fas.harvard.edu>
    Type: Standard
    Category: ERC
    Status: Draft
    Created: 2018-03-07

# Summary
A standard interface for mineable tokens.

# Abstract
The following standard allows for the implementation of a standard API for mineable tokens within smart contracts. This standard provides basic functionality to mine and reward ERC20 tokens with a Proof of Work scheme.

# Motivation
A standard interface allows any Mineable ERC20 Tokens on Ethereum to be handled by general-purpose applications. Tokens within the Ethereum ecosystem may still require economic incentivization that proof of work mining provides. Specifically, the smart contract implementation will allow for Mineable ERC20 tokens to be tracked in standardized wallets, traded on exchanges, and interfaced with standardized third party mining tools and equipment.

# Specification
## Token
### ERC-20 compatibility Methods

#### name

Returns the name of the token - e.g. `"0xBitcoin Token"`.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

``` js
function name() constant returns (string name)
```

#### symbol

Returns the symbol of the token. e.g. `"0xDOGE"`.

OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

``` js
function symbol() constant returns (string symbol)
```
#### totalSupply

Returns the total token supply.

``` js
function totalSupply() constant returns (uint256 totalSupply)
```

#### balanceOf

Returns the account balance of another account with address `_owner`.

``` js
function balanceOf(address _owner) constant returns (uint256 balance)
```

### Mining Operations


#### mint

Returns a flag indicating a successful hash digest verification. In order to prevent MiTM attacks, it is recommended that the digest include a recent ethereum block hash and msg.sender's address. Once verified, the mint function calculates and delivers a mining reward to the sender and performs internal accounting operations on the contract's supply.

``` js
function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success)
```

##### *Mint Event*

Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address, the reward amount, the epoch count and newest challenge number.

``` js
event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
```

#### getChallengeNumber

Recent ethereum block hash, used to prevent pre-mining future blocks.

``` js
function getChallengeNumber() public constant returns (bytes32) 
```

#### getMiningDifficulty

The number of digits that the digest of the PoW solution requires which typically auto adjusts during reward generation.

``` js
function getMiningDifficulty() public constant returns (uint)
```

#### getMiningReward

Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era as tokens are mined to provide scarcity.

``` js
function getMiningReward() public constant returns (uint)
```

### Mining Debug Operations


#### getMintDigest

Returns a test digest using the same hashing scheme used when minting new tokens.

``` js
function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest)
```
OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.


#### checkMintSolution

Verifies a sample solution using the same scheme as the mint method.

``` js
function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) 
```
OPTIONAL - This method can be used to improve usability,
but interfaces and other contracts MUST NOT expect these values to be present.

## Implementation

At the time of writing this specification there is only one known reference implemention of this protocol available, 0xbitcoin.

#### An example implementation is available at
- https://github.com/0xbitcoin/0xbitcoin-token/blob/master/contracts/_0xBitcoinToken.sol

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
