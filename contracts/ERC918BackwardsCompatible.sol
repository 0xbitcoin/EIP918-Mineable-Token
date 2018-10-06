pragma solidity ^0.4.24;

import "./AbstractERC918.sol";

/**
 * @title ERC-918 Mineable Token Standard, optional backwards compatibility function
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-918.md
 * 
 */
contract ERC918BackwardsCompatible {

    function getAdjustmentInterval() public view returns (uint);

    function getChallengeNumber() public view returns (bytes32);

    function getMiningDifficulty() public view returns (uint);

    function getMiningTarget() public view returns (uint);

    function getMiningReward() public view returns (uint);

    function mint(uint256 _nonce) public returns (bool success);

    /*
     * @notice Externally facing mint function kept for backwards compatability with previous mint() definition
     * @param _nonce the solution nonce
     * @param _challenge_digest the keccak256 encoded challenge number + message sender + solution nonce
     **/
    function mint(uint256 _nonce, bytes32 _challenge_digest) public returns (bool success) {
        //the challenge digest must match the expected
        bytes32 digest = keccak256( abi.encodePacked(getChallengeNumber(), msg.sender, _nonce) );
        require(digest == _challenge_digest, "Challenge digest does not match expected digest on token contract [ ERC918BackwardsCompatible.mint() ]");
        success = mint(_nonce);
    }
}
