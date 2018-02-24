pragma solidity^0.4.19;

import "./lottery.sol";
import "ds-test/test.sol";

contract LotteryMock is Lottery {
    function LotteryMock(Token _token, Forum _forum) Lottery(_token, _forum) public {}
    function setRewardPool(uint256 _rewardPool) public {
        rewardPool = _rewardPool;
    }
    uint256 _now;
    function warp(uint256 _warp) external {
        _now += _warp;
    }
    function era() internal view returns (uint256) {
        return _now;
    }
}
contract LotteryTest is DSTest {
    Token token;
    Forum forum;
    LotteryMock lottery;
    function setUp() public {
        token = new Token(5);
        forum = new Forum();
        lottery = new LotteryMock(token, forum);
    }
    function test_reward() public {
        lottery.setRewardPool(5000);
        assertEq(lottery.reward(0), 2000);
        assertEq(lottery.reward(1), 1250);
        assertEq(lottery.reward(2), 1000);
        assertEq(lottery.reward(3), 500);
        assertEq(lottery.reward(4), 250);

        assertEq(lottery.rewardPool(),
            lottery.reward(0)
            + lottery.reward(1)
            + lottery.reward(2)
            + lottery.reward(3)
            + lottery.reward(4)
        );
    }

    function testFail_earlyEpoch() public {
        lottery.endEpoch();
    }
    function testFail_earlySecondEpoch() public {
        nextEpoch();
        lottery.endEpoch();
    }

    function assertNoWinners() internal {
        assertEq(lottery.payouts(0), 0);
        assertEq(lottery.payouts(1), 0);
        assertEq(lottery.payouts(2), 0);
        assertEq(lottery.payouts(3), 0);
        assertEq(lottery.payouts(4), 0);
    }
    function nextEpoch() internal {
        lottery.warp(1 days);
        lottery.endEpoch();
    }

    function test_emptyEpoch() public {
        nextEpoch();
        assertNoWinners();
        nextEpoch();
        assertNoWinners();
        
        forum.post(0x0, 0x0);
        lottery.upvote(1);
        nextEpoch();
        assertNoWinners();
    }

    function test_epoch() public {
        forum.post(0x0, 0x0);
        forum.post(0x0, 0x0);

        nextEpoch();
        assertNoWinners();
        assertEq(lottery.epochPrior(), 0);
        assertEq(lottery.epochCurrent(), 3);

        forum.post(0x0, 0x0);
        lottery.upvote(2);
        lottery.upvote(1);
        lottery.upvote(3);
        nextEpoch();
        assertEq(lottery.payouts(0), this);
        assertEq(lottery.payouts(1), this);
        assertEq(lottery.payouts(2), 0);
        assertEq(lottery.payouts(3), 0);
        assertEq(lottery.payouts(4), 0);
        assertEq(lottery.epochCurrent(), lottery.epochPrior() + 1);
        //lottery.claim(0);
        //lottery.claim(1);

        lottery.downvote(3);
        nextEpoch();
        assertNoWinners();
    }
}
