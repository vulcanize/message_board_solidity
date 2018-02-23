pragma solidity^0.4.19;

import "./lottery.sol";
import "ds-test/test.sol";

contract LotteryMock is Lottery {
    function setRewardPool(uint256 _rewardPool) public {
        rewardPool = _rewardPool;
    }
}
contract LotteryTest is DSTest {
    LotteryMock lottery;
    function setUp() public {
        lottery = new LotteryMock();
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
}
