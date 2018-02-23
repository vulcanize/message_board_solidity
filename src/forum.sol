pragma solidity^0.4.19;

contract Forum {
    address[] public posters;

    function Forum () public {
        posters.push(0); // no author for root post 0
    }

    function postCount() public view returns (uint256) {
        return posters.length;
    }

    event Topic(bytes32 parent, bytes32 contentHash);
    // a parent of 0x0 indicates root topic
    function post(bytes32 _parent, bytes32 _contentHash) external {
        Topic(_parent, _contentHash);
        posters.push(msg.sender);
    }
}
