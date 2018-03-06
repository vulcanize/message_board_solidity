pragma solidity^0.4.19;

import "ds-token/token.sol";
import "./redeemer.sol";

interface Beneficiary {
    function setToken(ERC20 _to, Redeemer _redeemer) external;
}

contract Forum {
    address[] public posters;

    // this token *must* assert in transferFrom without allowance
    ERC20 public token;
    // receives all the tokens
    Beneficiary public beneficiary;
    address public owner;

    function Forum (ERC20 _token) public {
        token = _token;
        owner = msg.sender;
        posters.push(0); // no author for root post 0
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function setBeneficiary(Beneficiary _beneficiary) external onlyOwner {
        beneficiary = _beneficiary;
    }

    function setToken(ERC20 _to, Redeemer _redeemer) external onlyOwner {
        beneficiary.setToken(_to, _redeemer);
        token = _to;
    }

    function postCount() public view returns (uint256) {
        return posters.length;
    }

    // a parent of 0x0 indicates root topic
    // by convention, the bytes32 is a SHA2-256 content hash
    event Topic(uint256 _parent, bytes32 contentHash);
    function post(uint256 _parent, bytes32 _contentHash) external {
        require(token.transferFrom(msg.sender, beneficiary, 1 ether));
        Topic(_parent, _contentHash);
        posters.push(msg.sender);
    }
}
