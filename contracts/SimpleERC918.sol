pragma solidity ^0.4.18;

import "./AbstractERC918.sol";

/**
 * Simple ERC918 Implementation
 * Proof of Work Mineable Token
 *
 * This Abstract contract implements a minimal set of behaviors (hash, reward, epoch, and difficulty adjustment) 
 * and state required to build a Proof of Work driven mineable token.
 * 
 * https://github.com/ethereum/EIPs/pull/918
 * https://www.ethereum.org/token#proof-of-work
 */
contract SimpleERC918 is AbstractERC918 {
    
    uint public timeOfLastProof;    // Variable to keep track of when rewards were given
    
    function SimpleERC918() public {
        // Difficulty starts reasonably low
        difficulty = 10**32;
    }
    
    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest) {
        digest = bytes32(keccak256(nonce, challenge_digest));    // Generate a random hash based on input
        require(digest >= bytes32(difficulty));                   // Check if it's under the difficulty
    }
    
    function _reward() internal returns (uint rewardAmount) {
        uint timeSinceLastProof = (now - timeOfLastProof);  // Calculate time since last reward was given
        require(timeSinceLastProof >=  5 seconds);         // Rewards cannot be given too quickly
        rewardAmount = timeSinceLastProof / 60 seconds;
        balances[msg.sender] += rewardAmount;  // The reward to the winner grows by the minute
    }
    
    function _newEpoch(uint256 nonce) internal returns (uint) {
        timeOfLastProof = now;  // Reset the counter
        challengeNumber = keccak256(nonce, challengeNumber, block.blockhash(block.number - 1));  // Save a hash that will be used as the next proof
    }
    
    function _adjustDifficulty() internal returns (uint) {
        uint timeSinceLastProof = (now - timeOfLastProof);  // Calculate time since last reward was given
        difficulty = difficulty * 10 minutes / (timeSinceLastProof + 1);  // Adjusts the difficulty
    }

}