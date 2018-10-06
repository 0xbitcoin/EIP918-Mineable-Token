pragma solidity ^0.4.24;

import "./0xBitcoinBase.sol";
/* Create a 0xb based mineable token */
contract _0xdoge is _0xBitcoinBase('0xDoge', '0xDoge Mineable Token', 113000000000, 12, 200, 512) { 

	/**
	 * hash function
	 *
	 * Override the default hash phase of the mine operation
	 */
	function hash(uint256 _nonce, address _origin) public returns (bytes32 digest) {
		/* call the base implementation of _hash if need be */
		digest = super.hash(_nonce, _origin);
		/* doge specific nonce and challenge checks here */
	}

}