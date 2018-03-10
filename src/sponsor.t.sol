pragma solidity^0.4.19;

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
}
