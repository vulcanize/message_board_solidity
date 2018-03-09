pragma solidity^0.4.19;

import "erc20/erc20.sol";
import "./redeemer.sol";

interface Beneficiary {
    function redeem(Redeemer _redeemer) external returns (ERC20);
    function undo(Redeemer _redeemer) external returns (ERC20);
    function onPost(address _poster) external;
    function onPostUpvote(address _poster) external;
}

contract ForumEvents {
    // the total ordering of all events on a smart contract is defined
    // a parent of 0x0 indicates root topic
    // by convention, the bytes32 is a keccak-256 content hash
    // the multihash prefix for this is 1b,20
    event Topic(uint256 _parent, bytes32 contentHash);
}

contract Forum is ForumEvents {

    // though ERC20 says tokens *should* revert in transferFrom without allowance
    // this token *must* revert
    ERC20 public token;
    // receives all the post tokens
    Beneficiary public beneficiary;
    address public owner;

    function Forum (ERC20 _token) public {
        token = _token;
        owner = msg.sender;
        Topic(0, 0);
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

    function redeem(Redeemer _redeemer) external onlyOwner {
        token = beneficiary.redeem(_redeemer);
    }
    function undo(Redeemer _redeemer) external onlyOwner {
        token = beneficiary.undo(_redeemer);
    }

    function post(uint256 _parent, bytes32 _contentHash) external {
        token.transferFrom(msg.sender, beneficiary, 20 finney);
        Topic(_parent, _contentHash);
        beneficiary.onPost(msg.sender);
    }

    function postAndUpvote(uint256 _parent, bytes32 _contentHash) external {
        token.transferFrom(msg.sender, beneficiary, 40 finney);
        Topic(_parent, _contentHash);
        beneficiary.onPostUpvote(msg.sender);
    }
}
