// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BlindAuction} from "../src/BlindAuction.sol";

contract BlindAuctionTest is Test {
    BlindAuction public blindAuction;

    function setUp() public {
        blindAuction = new BlindAuction(1 days, 2 days, payable(address(1)));
    }
}
