## ERC Mineable Token Specification
#### This Specification has been moved to Ethereum EIP for Draft Review:

pull request:
https://github.com/ethereum/EIPs/pull/918


### Simple Summary

A specification for a standardized Mineable Token that uses a Proof of Work algorithm for distribution. 

### Abstract

 This specification describes a method for initially locking tokens within a token contract and slowly dispensing them with a mint() function which acts like a faucet.  This mint() function typically requires a Proof of Work algorithm in order to minimize gas fees. Standardized CPU and GPU token mining software exists.

### Motivation

Token distribution via ICO is at best full of scams at and worst totally illegal.  Furthermore, new token projects are all centralized because a single entity must handle and control all of the initial coins and all of the the raised ICO money.  By distribution tokens via an Initial Mining Offering (known as an IMO), the ownership of the token contract no longer belongs with the deployer at all and the deployer is 'just another user.' Furthermore, investor risk exposure is significantly diminished.  Projects incorporating ERC20/ERC721 tokens can now be completely decentralized like the Bitcoin community and Ethereum development community.   


--Complete the Below--
(The IMO mining period may last as short as one month or even one day, that is up to the deployer.   )

### Specification
 
The most important method for EIP918 is mint() for the token distribution and it is incorporated as follows for a SHA3 algorithm: 


     uint challengeNumber = block.blockhash(block.number - 1);
     uint miningTarget = 2**224;
     epochCount = 0;

     function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) { 
                 
                 bytes32 digest =  keccak256(challengeNumber, msg.sender, nonce);

                 //the challenge digest must match the expected
                 if (digest != challenge_digest) revert();

                 //the digest must be smaller than the target
                 if(uint256(digest) > miningTarget) revert(); 

                 //only allow one reward for each unique proof of work
                 bytes32 solution = solutionForChallenge[challengeNumber];
                 solutionForChallenge[challengeNumber] = digest;
                 if(solution != 0x0) revert();  
                
                 //need to implement a custom method for number of tokens to reward for a mint
                 uint rewardAmount = getMiningReward();
                
                 //use safe math to add tokens to the miners account
                 balances[msg.sender] = balances[msg.sender].add(rewardAmount);

                 //set the challenge number to a 'random' new value so future blocks cannot be premined
                 challengeNumber = block.blockhash(block.number - 1);
                 
                 //A method can be added here which adjusts the mining target in order to adjust difficulty
                 //_adjustMiningTarget()
                 
                 //track the number of mints that have occured
                 epochCount = epochCount.add(1);
                 
                 //fire an event
                 Mint(msg.sender, rewardAmount, epochCount, challengeNumber );

                 return true;

            }
            
            function getChallengeNumber() public constant returns (bytes32) {
            return challengeNumber;
            }
           
           function getMiningTarget() public constant returns (uint) {
             return miningTarget;
           }
   

A general mining function written in python for finding a valid nonce is as follows: 

--ADD ME --



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
Copyright and related rights waived via CC0.
