// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console, Vm} from "forge-std/Test.sol";
import {SimpleAuction} from "../src/SimpleAuction.sol";

contract SimpleAuctionTest is Test {
    SimpleAuction public simpleAuction;

    function setUp() public {
        simpleAuction = new SimpleAuction(uint256(100_0000), payable(address(1)));
    }

    function testBidSuccess() public {
        payable(address(2)).transfer(1 ether);
        payable(address(3)).transfer(1 ether);
        payable(address(4)).transfer(1 ether);
        vm.startPrank(address(2));
        simpleAuction.bid{value: 0.08 ether}();
        assertEq(simpleAuction.highestBidder(), address(2));
        assertEq(simpleAuction.highestBid(), 0.08 ether);
        vm.stopPrank();
        vm.startPrank(address(3));
        simpleAuction.bid{value: 0.1 ether}();
        assertEq(simpleAuction.highestBidder(), address(3));
        assertEq(simpleAuction.highestBid(), 0.1 ether);
        vm.stopPrank();

        vm.startPrank(address(4));
        vm.expectRevert();
        simpleAuction.bid{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(address(4));
        vm.expectRevert();
        simpleAuction.bid{value: 0.09 ether}();
        vm.stopPrank();

        vm.startPrank(address(4));
        simpleAuction.bid{value: 0.2 ether}();
        assertEq(simpleAuction.highestBidder(), address(4));
        assertEq(simpleAuction.highestBid(), 0.2 ether);
        vm.stopPrank();
    }
}
