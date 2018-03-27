---
eip: <to be assigned>
title: Mineable Token Standard
author: Jay Logelin, Infernal_toast, Michael Seiler
discussions-to: jlogelin@fas.harvard.edu, admin@0xbitcoin.org, mgs33@cornell.edu
status: Draft
type: Standards Track
category: ERC
created: 2018-03-07
---
 
### Simple Summary

A specification for a standardized Mineable Token that uses a Proof of Work algorithm for distribution. 

### Abstract

This specification describes a method for initially locking tokens within a token contract and slowly dispensing them with a mint() function which acts like a faucet. This mint() function uses a Proof of Work algorithm in order to minimize gas fees and control the distribution rate. Standardized CPU and GPU token mining software exists.

### Motivation

Token distribution via the ICO model and it's derivatives is susceptable to illicit behavior by human actors. Furthermore, new token projects are centralized because a single entity must handle and control all of the initial coins and all of the the raised ICO money.  By distributing tokens via an Initial Mining Offering (known as an IMO), the ownership of the token contract no longer belongs with the deployer at all and the deployer is 'just another user.' As a result, investor risk exposure utilizing a mined token distribution model is significantly diminished. This standard is intended to be standalone, allowing maximum interoperability with ERC20, ERC721, and others.

### Specification
 
### Fields

#### challengeNumber
The current challenge number. It is expected tha a new challenge number is generated after a new reward is minted.

``` js
bytes32 public challengeNumber;
```

#### difficulty
The current mining difficulty which should be adjusted via the \_adjustDifficulty minting phase

``` js
uint public difficulty;
```

#### tokensMinted
Cumulative counter of the total minted tokens, usually modified during the \_reward phase

``` js
uint public tokensMinted;
```

### Mining Operations

#### mint

Returns a flag indicating a successful hash digest verification, and reward allocation to msg.sender. In order to prevent MiTM attacks, it is recommended that the digest include a recent ethereum block hash and msg.sender's address. Once verified, the mint function calculates and delivers a mining reward to the sender and performs internal accounting operations on the contract's supply.

The mint operation exists as a public function that invokes 4 separate phases, represented as internal functions \_hash, \_reward, \_newEpoch, and \_adjustDifficulty. In order to create the most flexible implementation while adhering to a necessary contract protocol, it is recommended that token implementors override the internal methods, allowing the base contract to handle their execution via mint.

This externally facing function is called by miners to validate challenge digests, calculate reward,
populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
a Mint event is emitted before returning a boolean success flag.

``` js
// cumulative counter of the total minted tokens
uint public tokensMinted;
    
// track read only minting statistics
struct Statistics {
    address lastRewardTo;
    uint lastRewardAmount;
    uint lastRewardEthBlockNumber;
    uint lastRewardTimestamp;
}

Statistics public statistics;

function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {
    // perform the hash function validation
    _hash(nonce, challenge_digest);
    
    // calculate the current reward
    uint rewardAmount = _reward();
    
    // increment the minted tokens amount
    tokensMinted += rewardAmount;
    
    uint epochCount = _newEpoch(nonce);
    
    _adjustDifficulty();
    
     //populate read only diagnostics data
    statistics = Statistics(msg.sender, rewardAmount, block.number, now);
 
   
    // send Mint event indicating a successful implementation
    Mint(msg.sender, rewardAmount, epochCount, challengeNumber);
    
    return true;
}
```

##### *Mint Event*

Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address, the reward amount, the epoch count and newest challenge number.

``` js
event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
```

#### merge

*Optional*

Operationally similar to mint, except the merge function offers a list of token target addresses intended to be used to merge multiple token rewards.

``` js
function merge(uint256 nonce, bytes32 challenge_digest, address[] mineTokens) public returns (bool success);
```

#### \_hash

Internal interface function \_hash, meant to be overridden in implementation to define hashing algorithm and validation. Returns the validated digest

``` js
function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest);
```

#### \_reward

Internal interface function \_reward, meant to be overridden in implementation to calculate and allocate the reward amount. The reward amount must be returned by this method.

``` js
function _reward() internal returns (uint);
```

#### \_newEpoch

Internal interface function \_newEpoch, meant to be overridden in implementation to define a cutpoint for mutating mining variables in preparation for the next phase of mine.

``` js
function _newEpoch(uint256 nonce) internal returns (uint);
```
 
#### \_adjustDifficulty
 
Internal interface function \_adjustDifficulty, meant to be overridden in implementation to adjust the difficulty (via field difficulty) of the mining as required

``` js
function _adjustDifficulty() internal returns (uint);
```

#### getChallengeNumber

Recent ethereum block hash, used to prevent pre-mining future blocks.

``` js
function getChallengeNumber() public constant returns (bytes32) 
```

#### getMiningDifficulty

The number of digits that the digest of the PoW solution requires which typically auto adjusts during reward generation.Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era as tokens are mined to provide scarcity.


``` js
function getMiningDifficulty() public constant returns (uint)
```

#### getMiningReward

Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era as tokens are mined to provide scarcity.

``` js
function getMiningReward() public constant returns (uint)
```

### Example mining function
A general mining function written in python for finding a valid nonce is as follows: 
```
def mine(challenge, public_address, difficulty):
  while True:
    nonce = generate_random_number()
    hash1 = int(sha3.keccak_256(challenge+public_address+nonce).hexdigest(), 16)
    if hash1 < difficulty:
      return nonce, hash1
```

Once the nonce and hash1 are found, these are used to call the mint() function of the smart contract to receive a reward of tokens.

### Rationale
(The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.)

A keccak256 algoritm does not have to be used, but it is used in this case since it is a cost effective one-way algorithm to perform in the EVM and simple to perform in solidity.  The nonce is the solution that miners try to find and so it is part of the hashing algorithm.  A challengeNumber is also part of the hash so that future blocks cannot be mined since it acts like a random piece of data that is not revealed until a mining round starts.  The msg.sender address is part of the hash so that a nonce solution is valid only for a particular Ethereum account and so the solution is not susceptible to man-in-the-middle attacks.  This also allows pools to operate without being easily cheated by the miners since pools can force miners to mine using the pool's address in the hash algo.  

One community concern for mined tokens has been a concern of energy use without a function for securing a network.  Although token mining does not secure a network, it does secure a community from corruption since it eliminates monarchs and eliminates ICOs.  Furthermore, an IMO (initial mining offering) may last as little as a week, a day, or an hour at which point all of the tokens have been minted.  

### Backwards Compatibility
(All EIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The EIP must explain how the author proposes to deal with these incompatibilities. EIP submissions without a sufficient backwards compatibility treatise may be rejected outright.)

Backwards incompatibilities are not introduced.  

### Test Cases
(Test cases for an implementation are mandatory for EIPs that are affecting consensus changes. Other EIPs can choose to include links to test cases if applicable.)


### Implementation
(The implementations must be completed before any EIP is given status "Final", but it need not be completed before the EIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.)

0xBitcoin Token Contract: 
https://etherscan.io/address/0xb6ed7644c69416d67b522e20bc294a9a9b405b31

MVI OpenCL Token Miner 
https://github.com/mining-visualizer/MVis-tokenminer/releases


### Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
