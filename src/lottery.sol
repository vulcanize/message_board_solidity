pragma solidity^0.4.19;

import "./token.sol";

contract Lottery {
    Token token;
    uint256 epochOne;
    uint256 epochTwo;
    mapping (uint256 => uint256) votes;

    uint256 public rewardPool;
    address[6] public payouts;

    function vote(uint256 _offset) external {
        votes[_offset]++;
        token.transferFrom(msg.sender, this, 1);// TODO determine actual consumption
    }
    function endEpoch() external {
        // TODO
        rewardPool = token.balanceOf(this);
    }
    function reward(uint8 _payout) public view returns (uint256) {
        // I wish we had switch()
        if (_payout == 0) {
            return rewardPool * 2 / 5;
        } else if (_payout == 1) {
            return rewardPool / 4;
        } else if (_payout == 2) {
            return rewardPool / 5;
        } else if (_payout == 3) {
            return rewardPool / 10;
        } else if (_payout == 4) {
            return rewardPool / 20;
        }
        return 0;
    }
    function claim(uint8 _payout) external {
        require(payouts[_payout] == msg.sender);
        payouts[_payout] = 0;
        token.transfer(msg.sender, reward(_payout));
    }
}
