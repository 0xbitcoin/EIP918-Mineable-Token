pragma solidity ^0.4.24;

contract ERC918  {

    /*
     * @notice Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     * @param _nonce the solution nonce
     **/
  	function mint(uint256 nonce) public returns (bool success);

    /*
     * Returns the time in seconds between difficulty adjustments
     **/
    function getAdjustmentInterval() public view returns (uint);

	/*
     * Returns the challenge number
     **/
    function getChallengeNumber() public view returns (bytes32);

    /*
     * Returns the mining difficulty. The number of digits that the digest of the PoW solution requires which 
     * typically auto adjusts during reward generation.
     **/
    function getMiningDifficulty() public view returns (uint);

    /*
     * Returns the mining target
     **/
    function getMiningTarget() public view returns (uint);

    /*
     * Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era 
     * as tokens are mined to provide scarcity
     **/
    function getMiningReward() public view returns (uint);

    /*
     * Public hash function of the mineable token that validates the correct solution nonce against the
     * current mining target. The solution is stored in a local map, to prevent multiple submissions
     *
     * @param _nonce the solution nonce submitted through the mint operation
     * @param _minter the address responsible for resolving the solution
     **/
    function hash(uint256 _nonce, address _minter) public returns (bytes32 digest);
    
    /**
     * Internal function that performs difficulty adjustment phase of the mineable contract.
     * Returns the resulting current difficulty
     */
    function _reward(address _minter) internal returns (uint);
    
    /**
     * Internal function that performs epoch phase updates to the contract. If max supply for the era will be exceeded next 
     * reward round then assign a new era. Once the final era is reached, more tokens will not be given out and the mint operation
     * will fail to execute.
     * 
     * returns the resulting current epoch count
     */
    function _epoch() internal returns (uint);
    
    /*
     * Internal interface function _adjustDifficulty. Overide in implementation to adjust the difficulty
     * of the mining as required
     **/
    function _adjustDifficulty() internal returns (uint);
    
    /*
     * Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address, 
     * the reward amount, the epoch count and newest challenge number.
     **/
    event Mint(address indexed from, uint rewardAmount, uint epochCount, bytes32 newChallengeNumber);

}
