pragma solidity ^0.4.24;

import "./ECDSA.sol";
import "./AbstractERC918.sol";

contract ERC918DelgatedMint is AbstractERC918, ECDSA {
	/**
     * @notice Hash (keccak256) of the payload used by delegatedMint
     * @param _nonce the golden nonce
     * @param _origin the original minter
     * @param _signature the original minter's eliptical curve signature
     */
    function delegatedMint(uint256 _nonce, address _origin, bytes _signature) public returns (bool success) {
        bytes32 hashedTx = delegatedMintHashing(_nonce, _origin);
        address minter = recover(hashedTx, _signature);
        require(minter == _origin, "Origin minter address does not match recovered signature address [ AbstractERC918.delegatedMint() ]");
        require(minter != address(0), "Invalid minter address recovered from signature [ AbstractERC918.delegatedMint() ]");
        success = mintInternal(_nonce, minter);
    }

    /**
     * @notice Hash (keccak256) of the payload used by delegatedMint
     * @param _nonce the golden nonce
     * @param _origin the original minter
     */
    function delegatedMintHashing(uint256 _nonce, address _origin) public pure returns (bytes32) {
        /* "0x7b36737a": delegatedMintHashing(uint256,address) */
        return toEthSignedMessageHash(keccak256(abi.encodePacked( bytes4(0x7b36737a), _nonce, _origin)));
    }

    /*
     * @notice Internal mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     * @param _nonce the solution nonce
     * @param _minter the original minter of the solution
     **/
    function mintInternal(uint256 _nonce, address _minter) internal returns (bool success) {
        require(_minter != address(0), "Invalid address of 0x0 [ AbstractERC918.mintInternal() ]");

        // perform the hash function validation
        hash(_nonce, _minter);
        
        // calculate the current reward
        uint rewardAmount = _reward(_minter);
        
        // increment the minted tokens amount
        tokensMinted += rewardAmount;
        
        // increment state variables of current and new epoch
        epochCount = _epoch();

        //every so often, readjust difficulty. Dont readjust when deploying
        if(epochCount % blocksPerReadjustment == 0){
            _adjustDifficulty();
        }
       
        // send Mint event indicating a successful implementation
        emit Mint(_minter, rewardAmount, epochCount, challengeNumber);
        
        return true;
    }

    
}