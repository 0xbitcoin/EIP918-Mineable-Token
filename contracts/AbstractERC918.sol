pragma solidity ^0.4.24;

import "./ERC918.sol";

/**
 * ERC Draft Token Standard #918 Interface
 * Proof of Work Mineable Token
 *
 * This Abstract contract describes a minimal set of behaviors (hash, reward, epoch, and difficulty adjustment) 
 * and state required to build a Proof of Work driven mineable token.
 * 
 * http://eips.ethereum.org/EIPS/eip-918
 */
 contract AbstractERC918 is ERC918 {

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
   
    /*
     * @notice Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     * @param _nonce the solution nonce
     **/
    function mint(uint256 _nonce) public returns (bool success) {
        require(msg.sender != address(0), "Invalid address of 0x0 [ AbstractERC918.mintInternal() ]");

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

}
