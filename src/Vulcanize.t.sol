pragma solidity ^0.4.19;

import "ds-test/test.sol";

import "./Vulcanize.sol";

contract VulcanizeTest is DSTest {
    Vulcanize vulcanize;

    function setUp() public {
        vulcanize = new Vulcanize();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
