pragma solidity ^0.4.24;

import "./ERC918.sol";
import "./AbstractERC918.sol";

/**
 * @title ERC-918 Mineable Token Standard, optional merged mining functionality
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-918.md
 * 
 */
contract ERC918Merged is AbstractERC918 {
	/*
     * @notice Externally facing merge function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate state variables and adjust the solution difficulty as required. Additionally, the
     * merge function takes an array of target token addresses to be used in merged rewards. Once complete,
     * a Mint event is emitted before returning a success indicator.
     *
     * @param _nonce the solution nonce
     **/
    function merge(uint256 _nonce, address[] _mineTokens) public returns (bool) {
		for (uint i = 0; i < _mineTokens.length; i++) {
		  address tokenAddress = _mineTokens[i];
		  ERC918(tokenAddress).mint(_nonce);
		}
	}

	/*
     * @notice Externally facing merge function kept for backwards compatability with previous definition
     *
     * @param _nonce the solution nonce
     * @param _challenge_digest the keccak256 encoded challenge number + message sender + solution nonce
     **/
	function merge(uint256 _nonce, bytes32 _challenge_digest, address[] _mineTokens) public returns (bool) {
		//the challenge digest must match the expected
        bytes32 digest = keccak256( abi.encodePacked(challengeNumber, msg.sender, _nonce) );
        require(digest == _challenge_digest, "Challenge digest does not match expected digest on token contract [ ERC918Merged.mint() ]");
        return merge(_nonce, _mineTokens);
	}
}
