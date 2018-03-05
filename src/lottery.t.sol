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
contract Voter {
    Lottery lottery;
    Forum forum;
    Token token;
    function Voter (Lottery _lottery, Forum _forum, Token _token) public {
        lottery = _lottery;
        forum = _forum;
        token = _token;
        token.approve(lottery, 5 ether);
        token.approve(forum, 5 ether);
    }
    function upvote(uint _index) external {
        lottery.upvote(_index);
    }
    function downvote(uint _index) external {
        lottery.downvote(_index);
    }
    function post() external {
        forum.post(0x0, 0x0);
    }
}
contract LotteryTest is DSTest {
    Token token;
    Forum forum;
    LotteryMock lottery;
    function setUp() public {
        token = new Token(1000000000 ether);
        forum = new Forum(token);
        lottery = new LotteryMock(token, forum);
    }
    modifier test {
        token.approve(forum, 10 ether);
        token.approve(lottery, 10 ether);
        _;
    }
    function testFail_noApprovePost() public {
        forum.post(0x0,0x0);
    }
    function testFail_noApproveVote() public {
        lottery.upvote(0);
    }
    function test_reward() public test {
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

    function testFail_earlyEpoch() public test {
        lottery.endEpoch();
    }
    function testFail_earlySecondEpoch() public test {
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

    function test_emptyEpoch() public test {
        nextEpoch();
        assertNoWinners();
        nextEpoch();
        assertNoWinners();
        
        forum.post(0x0, 0x0);
        lottery.upvote(1);
        nextEpoch();
        assertNoWinners();
    }

    function test_epoch() public test {
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
        uint256 balance = token.balanceOf(this);
        lottery.claim(0);
        lottery.claim(1);
        uint256 balanceAfter = token.balanceOf(this);
        assertEq(balance + lottery.reward(0) + lottery.reward(1), balanceAfter);

        lottery.downvote(3);
        nextEpoch();
        assertNoWinners();
    }

    function test_epochRanking() public test {
        // 1
        forum.post(0x0, 0x0);
        // 2
        forum.post(0x0, 0x0);

        Voter v1 = new Voter(lottery, forum, token);
        token.transfer(v1, 10 ether);
        // 3
        v1.post();

        Voter v2 = new Voter(lottery, forum, token);
        token.transfer(v2, 10 ether);
        // 4
        v2.post();

        nextEpoch();
        assertNoWinners();

        // 1: +1
        lottery.upvote(1);
        v1.upvote(1);
        v2.downvote(1);

        // 2: -1
        lottery.downvote(2);
        v1.upvote(2);
        v2.downvote(2);

        // 3: +3
        lottery.upvote(3);
        v1.upvote(3);
        v2.upvote(3);

        // 4: +2
        lottery.upvote(4);
        v2.upvote(4);

        nextEpoch();
        assertEq(lottery.payouts(0), v1);
        assertEq(lottery.payouts(1), v2);
        assertEq(lottery.payouts(2), this);
        assertEq(lottery.payouts(3), 0x0);
    }

    function test_upvoteDownvote() public {
        // TODO
    }
}
