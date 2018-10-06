pragma solidity ^0.4.24;

import "./ERC918.sol";
import "./ERC918BackwardsCompatible.sol";
import "./ERC918Metadata.sol";
import "./ERC20StandardToken.sol";

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
contract SimpleERC918 is ERC918, ERC918BackwardsCompatible, ERC918Metadata, ERC20StandardToken {
    
    uint public MINIMUM_TARGET = 2**16;

    uint public MAXIMUM_TARGET = 2**234;

    // the amount of time between difficulty adjustments
    uint public adjustmentInterval = 10 minutes;
     
    // generate a new challenge number after a new reward is minted
    bytes32 public challengeNumber;
    
    // the current mining target
    uint public miningTarget;

    // cumulative counter of the total minted tokens
    uint public tokensMinted;

    // number of blocks per difficulty readjustment
    uint public blocksPerReadjustment;

    // number of 'blocks' mined
    uint public epochCount;
    
    // Variable to keep track of when rewards were given
    uint public timeOfLastProof;    

    // optional metadataURI URI containing ERC918 Token Metadata
    string public metadataURI;

    uint public difficulty = MINIMUM_TARGET;

    uint public miningReward = 50*10**18;

    function mint(uint256 _nonce) public returns (bool success) {

        // perform the hash function validation
        hash(_nonce, msg.sender);
        
        // calculate the current reward
        uint rewardAmount = _reward(msg.sender);
        
        // increment the minted tokens amount
        tokensMinted += rewardAmount;
        
        // increment state variables of current and new epoch
        epochCount = _epoch();

        //every so often, readjust difficulty. Dont readjust when deploying
        if(epochCount % blocksPerReadjustment == 0){
            _adjustDifficulty();
        }
       
        // send Mint event indicating a successful implementation
        emit Mint(msg.sender, rewardAmount, epochCount, challengeNumber);
        
        return true;
    }
    
    function hash(uint256 nonce, address _target) public returns (bytes32 digest) {
        digest = keccak256(abi.encodePacked(nonce, _target));    // Generate a random hash based on input
        require(digest >= bytes32(difficulty));                   // Check if it's under the difficulty
    }
    
    function _reward(address _target) internal returns (uint rewardAmount) {
        uint timeSinceLastProof = (now - timeOfLastProof);  // Calculate time since last reward was given
        require(timeSinceLastProof >=  5 seconds);         // Rewards cannot be given too quickly
        rewardAmount = timeSinceLastProof / 60 seconds;
        balances[_target] += rewardAmount;  // The reward to the winner grows by the minute
    }
    
    function _epoch() internal returns (uint) {
        timeOfLastProof = now;  // Reset the counter
        challengeNumber = keccak256(abi.encodePacked(challengeNumber, blockhash(block.number - 1)));  // Save a hash that will be used as the next proof
    }
    
    function _adjustDifficulty() internal returns (uint) {
        uint timeSinceLastProof = (now - timeOfLastProof);  // Calculate time since last reward was given
        difficulty = difficulty * 10 minutes / (timeSinceLastProof + 1);  // Adjusts the difficulty
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a mineable asset.
     */
    function metadataURI() external view returns (string) {
        return metadataURI;
    }

    /**
     * Backwards compatibility with existing Token Mining software
     */
    function getAdjustmentInterval() public view returns (uint) {
        return adjustmentInterval;
    }

    function getChallengeNumber() public view returns (bytes32) {
        return challengeNumber;
    }

    function getMiningDifficulty() public view returns (uint){
        return MAXIMUM_TARGET.div(getMiningTarget());
    }

    function getMiningTarget() public view returns (uint) {
        return miningTarget;
    }

    function getMiningReward() public view returns (uint) {
        return miningReward;
    }

}