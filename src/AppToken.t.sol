pragma solidity^0.4.18;

import "ds-test/test.sol";
import "./AppToken.sol";

contract SomeGuy {
    AppToken token;
    function SomeGuy(AppToken _token) public {
        setToken(_token);
    }
    function setToken(AppToken _token) {
        token = _token;
    }
    function nominate(address _guy) external {
        token.nominate(_guy);
    }
    function revoke(address _guy) external {
        token.revoke(_guy);
    }
}
contract AppTokenTest is DSTest,AppTokenEvents {
    AppToken token;
    SomeGuy admin1;
    SomeGuy admin2;
    function setUp() public {
        admin1 = someGuy();
        admin2 = someGuy();
        token = new AppToken(this, admin1, admin2);
        admin1.setToken(token);
        admin2.setToken(token);
    }
    function someGuy() internal returns (SomeGuy) {
        return new SomeGuy(token);
    }
    function testFail_someGuyTriesToNominate() public {
        SomeGuy s1 = someGuy();
        s1.nominate(this);
    }
    function testFail_someGuyTriesToRevoke() public {
        SomeGuy s1 = someGuy();
        s1.revoke(this);
    }
    function test_adminsNominateNewAdmin() public {
        SomeGuy nominee = someGuy();
        expectEventsExact(token);

        Nominated(nominee, admin1);
        Nominated(nominee, admin2);
        Board(nominee);

        admin1.nominate(nominee);
        admin2.nominate(nominee);
    }
    function test_adminsRevokeAdmin() public {
        expectEventsExact(token);

        Denounced(this, admin1);
        Denounced(this, admin2);
        Revoked(this);

        admin1.revoke(this);
        admin2.revoke(this);
    }
}
