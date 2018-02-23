pragma solidity^0.4.19;

contract Forum {
    event Topic(bytes32 parent, bytes32 contentHash);
    // a parent of 0x0 indicates root topic
    function post(bytes32 _parent, bytes32 _contentHash) external {
        Topic(_parent, _contentHash);
    }
}
