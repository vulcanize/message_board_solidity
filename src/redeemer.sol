pragma solidity^0.4.19;

import "./token.sol";
// assumption: token upgrades through DappHub, such as https://etherscan.io/address/0x642ae78fafbb8032da552d619ad43f1d81e4dd7c#code
interface Redeemer {
    function redeem() external;
    function undo() external;
    function to() public view returns (ERC20);
    function from() public view returns (ERC20);
}
