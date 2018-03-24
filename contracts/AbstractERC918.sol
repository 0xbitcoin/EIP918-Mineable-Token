pragma solidity ^0.4.18;

import "./EIP918Interface.sol";

/**
 * ERC Draft Token Standard #918 Interface
 * Proof of Work Mineable Token
 *
 * This Abstract contract describes a minimal set of behaviors (hash, reward, epoch, and difficulty adjustment) 
 * and state required to build a Proof of Work driven mineable token.
 * 
 * https://github.com/ethereum/EIPs/pull/918
 */
 contract AbstractERC918 is EIP918Interface {
     
    // generate a new challenge number after a new reward is minted
    bytes32 public challengeNumber;
    
    // the current mining difficulty
    uint public difficulty;

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
    
    /*
     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
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
    
    /*
     * Internal interface function _hash. Overide in implementation to define hashing algorithm and 
     * validation
     **/
    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest);
    
    /*
     * Internal interface function _reward. Overide in implementation to calculate and return reward
     * amount
     **/
    function _reward() internal returns (uint);
    
    /*
     * Internal interface function _newEpoch. Overide in implementation to define a cutpoint for mutating
     * mining variables in preparation for the next epoch
     **/
    function _newEpoch(uint256 nonce) internal returns (uint);
    
    /*
     * Internal interface function _adjustDifficulty. Overide in implementation to adjust the difficulty
     * of the mining as required
     **/
    function _adjustDifficulty() internal returns (uint);

    /*
     * Returns the challenge number
     **/
    function getChallengeNumber() public constant returns (bytes32);

    /*
     * Returns the mining difficulty. The number of digits that the digest of the PoW solution requires which 
     * typically auto adjusts during reward generation.
     **/
    function getMiningDifficulty() public constant returns (uint);

    /*
     * Returns the mining target
     **/
    function getMiningTarget() public constant returns (uint);

    /*
     * Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era 
     * as tokens are mined to provide scarcity
     **/
    function getMiningReward() public constant returns (uint);
    
    /*
     * Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address, 
     * the reward amount, the epoch count and newest challenge number.
     **/
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
}
