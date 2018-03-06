pragma solidity^0.4.19;

// assumption: token upgrades through redeemer, such as https://etherscan.io/address/0x642ae78fafbb8032da552d619ad43f1d81e4dd7c#code
interface Redeemer {
    function redeem() external;
}
