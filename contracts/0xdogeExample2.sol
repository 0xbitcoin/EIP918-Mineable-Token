pragma solidity ^0.4.18;

import "./0xBitcoinBase.sol";
/* Create a 0xb based mineable token */
contract _0xdoge is _0xBitcoinBase('0xDoge', '0xDoge Mineable Token', 113000000000, 12, 200, 512) { 

	/**
	 * _hash function
	 *
	 * Override the default hash phase of the mine operation
	 */
	function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest) {
		/* call the base implementation of _hash if need be */
		digest = super._hash(nonce, challenge_digest);
		/* doge specific nonce and challenge checks here */

	}

}