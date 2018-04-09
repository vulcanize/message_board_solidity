// Copyright (c) William Morriss, 2018
pragma solidity^0.4.19;

import "./AppToken.sol";
// assumption: token upgrades through DappHub, such as https://etherscan.io/address/0x642ae78fafbb8032da552d619ad43f1d81e4dd7c#code
// assumption: token upgrades are 1:1
interface Redeemer {
    function redeem() external;
    function undo() external;
    function to() external view returns (AppToken);
    function from() external view returns (AppToken);
}
