pragma solidity^0.4.19;
// when you change the solidity version, run test_conflict with k=1000000

import "ds-test/test.sol";
import "./sponsored.sol";

contract SponsorTest is DSTest, Sponsored {
    function setUp() public {
    }
    function test_empty() public sponsored {
    }
    function test_sponsored() public sponsored {
        this.sponsor();
    }

    function responsor() internal sponsored {}

    uint256[] potentialConflictSpace;
    function test_conflict() public sponsored {
        uint256 k = 40;
        for (uint256 i = 0; i < k; i++) {
            potentialConflictSpace.push(i);
        }
        for (i = 0; i < k; i++) {
            this.sponsor();
        }
        for (i = 0; i < k; i++) {
            responsor();
        }
        for (i = 0; i < k; i++) {
            assertEq(potentialConflictSpace[i], i);
        }
    }
}
