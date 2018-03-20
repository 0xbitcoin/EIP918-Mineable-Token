// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
pragma solidity ^0.4.18;

import "./EIP20Interface.sol";

contract EIP541Interface is EIP20Interface {

  function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);

  function getChallengeNumber() public constant returns (bytes32);

  function getMiningDifficulty() public constant returns (uint);

  function getMiningTarget() public constant returns (uint);

  function getMiningReward() public constant returns (uint);

}
