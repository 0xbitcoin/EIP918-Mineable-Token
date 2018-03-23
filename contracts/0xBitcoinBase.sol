/*
 Implements EIP918 draft token standard: https://github.com/0xbitcoin/ERC541-Spec/blob/master/contracts/EIP541.sol
.*/
pragma solidity ^0.4.18;

import "./EIP20Interface.sol";
import "./AbstractERC918.sol";
import "./SafeMath.sol";
import "./ExtendedMath.sol";
import "./Owned.sol";

/**
 * _0xBitcoinBase Implementation used for creating ERC918, ERC20 mineable tokens using the same difficulty
 * adjustment, reward and hashing features of 0xBitcoin
 *
 * This complex contract implements a minimal set of behaviors (hash, reward, epoch, and difficulty adjustment) 
 * and state required to build a Proof of Work driven mineable token. Refactoring of 0xBitcoin base code to be
 * used for implementing 0xbitcoin based mineable tokens
 * 
 * https://github.com/ethereum/EIPs/pull/918
 * https://github.com/0xbitcoin/0xbitcoin-token/blob/master/contracts/_0xBitcoinToken.sol
 */
contract _0xBitcoinBase is AbstractERC918, EIP20Interface {
    using SafeMath for uint;
    using ExtendedMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public totalSupply;
    uint public latestDifficultyPeriodStarted;
    uint public epochCount;//number of 'blocks' mined
    uint public baseMiningReward;
    uint public blocksPerReadjustment;
    uint public _MINIMUM_TARGET = 2**16;
    uint public _MAXIMUM_TARGET = 2**234;
    uint public rewardEra;
    uint public maxSupplyForEra;
    uint public MAX_REWARD_ERA = 39;
    uint public MINING_RATE_FACTOR = 60; //mint the token 60 times less often than ether
    //difficulty adjustment parameters- be careful modifying these
    uint public MAX_ADJUSTMENT_PERCENT = 100;
    uint public TARGET_DIVISOR = 2000;
    uint public QUOTIENT_LIMIT = TARGET_DIVISOR.div(2);
    mapping(bytes32 => bytes32) solutionForChallenge;
    mapping(address => mapping(address => uint)) allowed;
    // balances of 
    mapping(address => uint) balances;
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function _0xBitcoinBase(
        string tokenSymbol,
        string tokenName,
        uint256 tokenSupply,
        uint8 tokenDecimals,
        uint initialReward,
        uint blocksPerDifficultyAdjustment
    ) public {
        symbol = tokenSymbol;
        name = tokenName;
        decimals = tokenDecimals;
        totalSupply = tokenSupply * 10**uint(decimals);
        baseMiningReward = initialReward;
        blocksPerReadjustment = blocksPerDifficultyAdjustment;
        // -- do not change lines below --
        tokensMinted = 0;
        rewardEra = 0;
        maxSupplyForEra = totalSupply.div(2);
        difficulty = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        _newEpoch(0);
    }

    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest) {
        digest =  keccak256(challengeNumber, msg.sender, nonce );
        //the challenge digest must match the expected
        if (digest != challenge_digest) revert();
        //the digest must be smaller than the target
        if(uint256(digest) > difficulty) revert();
        //only allow one reward for each challenge
        bytes32 solution = solutionForChallenge[challengeNumber];
        solutionForChallenge[challengeNumber] = digest;
        if(solution != 0x0) revert();  //prevent the same answer from awarding twice
    }
    
    //21m coins total
    //reward begins at 50 and is cut in half every reward era (as tokens are mined)
    function _reward() internal returns (uint) {
        //once we get half way thru the coins, only get 25 per block
        //every reward era, the reward amount halves.
        uint reward_amount = getMiningReward();
        balances[msg.sender] = balances[msg.sender].add(reward_amount);
        return reward_amount;
    }

    function _newEpoch(uint256 nonce) internal returns (uint) {
      //if max supply for the era will be exceeded next reward round then enter the new era before that happens
      //40 is the final reward era, almost all tokens minted
      //once the final era is reached, more tokens will not be given out because the assert function
      if( tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < MAX_REWARD_ERA)
      {
        rewardEra = rewardEra + 1;
      }
      //set the next minted supply at which the era will change
      // total supply is 2100000000000000  because of 8 decimal places
      maxSupplyForEra = totalSupply - totalSupply.div( 2**(rewardEra + 1));
      epochCount = epochCount.add(1);
      //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
      //do this last since this is a protection mechanism in the mint() function
      challengeNumber = block.blockhash(block.number - 1);
    }
    //DO NOT manually edit this method unless you know EXACTLY what you are doing
    function _adjustDifficulty() internal returns (uint) {
        //every so often, readjust difficulty. Dont readjust when deploying
        require(epochCount % blocksPerReadjustment == 0);
        
        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
        //assume 360 ethereum blocks per hour
        //we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one 0xbitcoin epoch
        uint epochsMined = blocksPerReadjustment;
        uint targetEthBlocksPerDiffPeriod = epochsMined * MINING_RATE_FACTOR;
        //if there were less eth blocks passed in time than expected
        if( ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod )
        {
          uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div( ethBlocksSinceLastDifficultyPeriod );
          uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT);
          // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.
          //make it harder
          difficulty = difficulty.sub(difficulty.div(TARGET_DIVISOR).mul(excess_block_pct_extra));   //by up to 50 %
        }else{
          uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div( targetEthBlocksPerDiffPeriod );
          uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT); //always between 0 and 1000
          //make it easier
          difficulty = difficulty.add(difficulty.div(TARGET_DIVISOR).mul(shortage_block_pct_extra));   //by up to 50 %
        }
        latestDifficultyPeriodStarted = block.number;
        if(difficulty < _MINIMUM_TARGET) //very difficult
        {
          difficulty = _MINIMUM_TARGET;
        }
        if(difficulty > _MAXIMUM_TARGET) //very easy
        {
          difficulty = _MAXIMUM_TARGET;
        }
    }
    //this is a recent ethereum block hash, used to prevent pre-mining future blocks
    function getChallengeNumber() public constant returns (bytes32) {
        return challengeNumber;
    }
    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
    function getMiningDifficulty() public constant returns (uint) {
        return _MAXIMUM_TARGET.div(difficulty);
    }
    function getMiningTarget() public constant returns (uint) {
       return difficulty;
    }

    //21m coins total
    //reward begins at 50 and is cut in half every reward era (as tokens are mined)
    function getMiningReward() public constant returns (uint) {
        //once we get half way thru the coins, only get 25 per block
         //every reward era, the reward amount halves.
         return (baseMiningReward * 10**uint(decimals) ).div( 2**rewardEra ) ;
    }
    
    //help debug mining software
    function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest) {
        bytes32 digest = keccak256(challenge_number,msg.sender,nonce);
        return digest;
      }
        //help debug mining software
    function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {
        bytes32 digest = keccak256(challenge_number,msg.sender,nonce);
        if(uint256(digest) > testTarget) revert();
        return (digest == challenge_digest);
    }
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return totalSupply  - balances[address(0)];
    }
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
    
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
