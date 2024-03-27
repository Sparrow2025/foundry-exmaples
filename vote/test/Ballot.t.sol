// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ballot} from "../src/Ballot.sol";

contract CounterTest is Test {
    Ballot public ballot;
    bytes32[] public names;

    function setUp() public {
        bytes32[] memory proposalNames = new bytes32[](2);
        proposalNames[0] = bytes32(unicode"剪刀");
        proposalNames[1] = bytes32(unicode"石头");
        ballot = new Ballot(proposalNames);
    }

    function test() public {
        assertNotEq(address(ballot), address(0));
    }
}
