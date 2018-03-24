The most important method for EIP918 is mint() for the token distribution and it is incorporated as follows for a SHA3 algorithm: 


     uint challengeNumber = block.blockhash(block.number - 1);
     uint miningTarget = 2**224;
     uint epochCount = 0;

     function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) { 
                 
                 bytes32 digest =  keccak256(challengeNumber, msg.sender, nonce);

                 //the challenge digest must match the expected
                 if (digest != challenge_digest) revert();

                 //the digest must be smaller than the target
                 if(uint256(digest) > miningTarget) revert(); 

                 //only allow one reward for each unique proof of work
                 bytes32 solution = solutionForChallenge[challengeNumber];
                 solutionForChallenge[challengeNumber] = digest;
                 if(solution != 0x0) revert();  
                
                 //implement a custom method for number of tokens to reward for a mint
                 uint rewardAmount = getMiningReward();
                
                 //use safe math to add tokens to the miners account
                 balances[msg.sender] = balances[msg.sender].add(rewardAmount);

                 //set the challenge number to a 'random' new value so future blocks cannot be premined
                 challengeNumber = block.blockhash(block.number - 1);
                 
                 //A method can be added here which adjusts the mining target in order to adjust difficulty
                 //_adjustMiningTarget()
                 
                 //track the number of mints that have occured
                 epochCount = epochCount.add(1);
                 
                 //fire an event
                 Mint(msg.sender, rewardAmount, epochCount, challengeNumber );

                 return true;

            }
            
            function getChallengeNumber() public constant returns (bytes32) {
            return challengeNumber;
            }
           
           function getMiningTarget() public constant returns (uint) {
             return miningTarget;
           }
           
           
           function getMiningReward() public constant returns (uint) {
             //Feel free to modify this integer 
             return 50 * 10**uint(decimals);
           }
