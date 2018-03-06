pragma solidity^0.4.19;

import "./forum.sol";
import "./redeemer.sol";

contract Lottery is Beneficiary {
    // this token *must* assert in transferFrom without allowance
    ERC20 token;
    Forum forum;
    uint256 public epochTimestamp;
    uint256 public epochPrior;
    uint256 public epochCurrent;
    mapping (uint256 => int256) public votes;
    mapping (uint256 => mapping (address => int8)) voters;

    uint256 public rewardPool;
    address[5] public payouts;

    function Lottery(ERC20 _token, Forum _forum) public {
        token = _token;
        forum = _forum;
    }

    modifier vote(uint256 _offset, int8 _direction) {
        int8 priorVote = voters[_offset][msg.sender];
        votes[_offset] += _direction - priorVote;
        voters[_offset][msg.sender] = _direction;
        require(token.transferFrom(msg.sender, this, 1 ether));
        _;
    }
    function upvote(uint256 _offset) external vote(_offset, 1) {
    }
    function downvote(uint256 _offset) external vote(_offset, -1) {
    }
    function unvote(uint256 _offset) external vote(_offset, 0) {
    }
    function endEpoch() external {
        require(era() >= epochTimestamp + 1 days);
        epochTimestamp = era();

        uint256[5] memory winners; 
        int256[5] memory topVotes;
        // get top 5 posts
        for (uint256 i = epochCurrent; i --> epochPrior;) {
            if (votes[i] == 0) {
                continue;
            }

            int256 current = votes[i];
            if (current > topVotes[4]) {
                // insert it
                // TODO consider funrolling this loop
                uint8 j = 4;
                while (topVotes[j-1] < current) {
                    topVotes[j] = topVotes[j-1];
                    winners[j] = winners[j-1];
                    j--;
                    if (j == 0) {
                        break;
                    }
                }
                topVotes[j] = current;
                winners[j] = i;
            }
            votes[i] = 0;
        }

        // write the new winners
        for (i = 0; i < 5; i++) {
            payouts[i] = forum.posters(winners[i]);
        }
        // refresh the pool
        rewardPool = token.balanceOf(this);
        epochPrior = epochCurrent;
        epochCurrent = forum.postCount();
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
    function setToken(ERC20 _to, Redeemer _redeemer) external {
        require(msg.sender == address(forum));
        token.approve(_redeemer, token.balanceOf(this));
        _redeemer.redeem();
        token = _to;
    }
    function era() internal view returns (uint256) {
        return now;
    }
}
