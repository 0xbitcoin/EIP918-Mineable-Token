pragma solidity ^0.4.24;

/**
 * @title ERC-918 Mineable Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-918.md
 * 
 * http://eips.ethereum.org/EIPS/eip-918
 */
interface ERC918Metadata {
    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a mineable asset.
     */
    function metadataURI() external view returns (string);
}
