pragma solidity^0.4.19;

import "./lottery.sol";
import "./token.sol";
import "ds-test/test.sol";

contract LotteryMock is Lottery {
    function LotteryMock(ERC20 _token, Forum _forum) Lottery(_token, _forum) public {}
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
contract RedeemerMock is Redeemer {
    ERC20 from;
    ERC20 to;
    function RedeemerMock(ERC20 _from, ERC20 _to) public {
        from = _from;
        to = _to;
    }
    function redeem() external {
        uint256 wad = from.balanceOf(msg.sender);
        from.transferFrom(msg.sender, this, wad);
        to.transfer(msg.sender, wad);
    }
}
contract Voter {
    Lottery lottery;
    Forum forum;
    ERC20 token;
    function Voter (Lottery _lottery, Forum _forum, Token _token) public {
        lottery = _lottery;
        forum = _forum;
        token = _token;
        token.approve(lottery, 10 ether);
        token.approve(forum, 10 ether);
    }
    function upvote(uint _index) external {
        lottery.upvote(_index);
    }
    function downvote(uint _index) external {
        lottery.downvote(_index);
    }
    function unvote(uint256 _index) external {
        lottery.unvote(_index);
    }
    function post() external {
        forum.post(0x0, 0x0);
    }
    function claim(uint8 _index) external {
        lottery.claim(_index);
    }
    function setToken(ERC20 _to) external {
        token = _to;
    }
    function trySetForumToken(ERC20 _to, Redeemer _redeemer) external {
        forum.setToken(_to, _redeemer);
    }
    function trySetLotteryToken(ERC20 _to, Redeemer _redeemer) external {
        lottery.setToken(_to, _redeemer);
    }
}
contract LotteryTest is DSTest {
    Token token;
    Forum forum;
    LotteryMock lottery;
    ERC20 successorToken;
    Redeemer redeemer;
    function setUp() public {
        uint256 supply  = 1000000000 ether;
        token = new Token(supply);
        forum = new Forum(token);
        lottery = new LotteryMock(token, forum);
        forum.setBeneficiary(lottery);
        successorToken = new Token(supply);
        redeemer = new RedeemerMock(token, successorToken);
        successorToken.transfer(redeemer, supply);
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

        v1.claim(0);
        v2.claim(1);
        lottery.claim(2);
    }

    function test_upvoteDownvote() public test {
        Voter v1 = new Voter(lottery, forum, token);
        token.transfer(v1, 10 ether);
        Voter v2 = new Voter(lottery, forum, token);
        token.transfer(v2, 10 ether);

        lottery.upvote(1);
        assertEq(lottery.votes(1), 1);
        v1.upvote(1);
        assertEq(lottery.votes(1), 2);
        v2.upvote(1);
        assertEq(lottery.votes(1), 3);
        lottery.downvote(1);
        assertEq(lottery.votes(1), 1);
        v1.downvote(1);
        assertEq(lottery.votes(1), -1);
        v2.downvote(1);
        assertEq(lottery.votes(1), -3);

        v2.downvote(2);
        assertEq(lottery.votes(2), -1);
        v1.downvote(2);
        assertEq(lottery.votes(2), -2);
        lottery.downvote(2);
        assertEq(lottery.votes(2), -3);

        assertEq(lottery.votes(3), 0);
        v2.unvote(3);
        assertEq(lottery.votes(3), 0);
        v1.upvote(3);
        assertEq(lottery.votes(3), 1);
        v2.upvote(3);
        assertEq(lottery.votes(3), 2);
        v2.downvote(3);
        assertEq(lottery.votes(3), 0);
        v2.unvote(3);
        assertEq(lottery.votes(3), 1);
    }

    function testFail_noTokens() public test {
        Voter v1 = new Voter(lottery, forum, token);
        v1.upvote(1);
    }

    function test_ownerUpgrade() public test {
        assertEq(forum.owner(), this);
        forum.setToken(successorToken, redeemer);
    }
    function testFail_forumUpgrade() public test {
        Voter v1 = new Voter(lottery, forum, token);
        v1.trySetForumToken(successorToken, redeemer);
    }
    function testFail_lotteryUpgrade() public test {
        Voter v1 = new Voter(lottery, forum, token);
        v1.trySetLotteryToken(successorToken, redeemer);
    }
}
