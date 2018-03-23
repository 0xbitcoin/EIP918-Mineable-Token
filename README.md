## ERC Mineable Token Specification
#### This Specification has been moved to Ethereum EIP for Draft Review:

pull request:
https://github.com/ethereum/EIPs/pull/918


### Simple Summary

A specification for a standardized Mineable Token that uses a Proof of Work algorithm for distribution. 

### Abstract

 This specification describes a method for initially locking tokens within a token contract and slowly dispensing them with a mint() function which acts like a faucet.  This mint() function typically requires a Proof of Work algorithm in order to minimize gas fees.

### Motivation

Token distribution via ICO is at best full of scams at and worst totally illegal.  Furthermore, new token projects are all centralized because a single entity must handle and control all of the initial coins and all of the the raised ICO money.  By distribution tokens via an Initial Mining Offering (known asan IMO), the ownership of the token contract no longer belongs with the deployer at all and the deployer is 'just another user.' Furthermore, investor risk is significantly diminished.  Projects incorporating tokens can now be completely decentralized like the Bitcoin community and Ethereum development community.  Finally, the IMO mining period may last as short as one month or even one day, that is up to the deployer.  



--Complete the Below--


### Specification
The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (cpp-ethereum, go-ethereum, parity, ethereumj, ethereumjs, ...).

### Rationale
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.

### Backwards Compatibility
All EIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The EIP must explain how the author proposes to deal with these incompatibilities. EIP submissions without a sufficient backwards compatibility treatise may be rejected outright.

### Test Cases
Test cases for an implementation are mandatory for EIPs that are affecting consensus changes. Other EIPs can choose to include links to test cases if applicable.

### Implementation
The implementations must be completed before any EIP is given status "Final", but it need not be completed before the EIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.

### Copyright
Copyright and related rights waived via CC0.
