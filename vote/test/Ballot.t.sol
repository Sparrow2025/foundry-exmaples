// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ballot} from "../src/Ballot.sol";

contract BallotTest is Test {
    Ballot public ballot;
    bytes32[] public names;

    uint256 internal firstVoterPrivateKey;
    uint256 internal secondVoterPrivateKey;
    uint256 internal thirdVoterPrivateKey;
    uint256 internal fourthVoterPrivateKey;

    address internal firstVoter;
    address internal secondVoter;
    address internal thirdVoter;
    address internal fourthVoter;

    function setUp() public {
        bytes32[] memory proposalNames = new bytes32[](2);
        proposalNames[0] = bytes32(unicode"同意");
        proposalNames[1] = bytes32(unicode"拒绝");
        ballot = new Ballot(proposalNames);

        firstVoterPrivateKey = 0xAAAA;
        secondVoterPrivateKey = 0xAAAB;
        thirdVoterPrivateKey = 0xAAAC;
        fourthVoterPrivateKey = 0xAAAD;

        firstVoter = vm.addr(firstVoterPrivateKey);
        secondVoter = vm.addr(secondVoterPrivateKey);
        thirdVoter = vm.addr(thirdVoterPrivateKey);
        fourthVoter = vm.addr(fourthVoterPrivateKey);

        ballot.giveRightToVote(firstVoter);
        ballot.giveRightToVote(secondVoter);
        ballot.giveRightToVote(thirdVoter);
    }

    function test_giveRightToVote() public {
        ballot.giveRightToVote(fourthVoter);
        (uint256 weight, bool voted,,) = ballot.voters(fourthVoter);
        assertEq(voted, false);
        assertEq(weight, 1);
    }

    function test_delegate() public {
        vm.prank(firstVoter);
        ballot.delegate(secondVoter);
        vm.prank(secondVoter);
        ballot.delegate(thirdVoter);
        (uint256 weight, bool voted,,) = ballot.voters(thirdVoter);
        assertEq(voted, false);
        assertEq(weight, 3);
        (uint256 weight1, bool voted1, address delegate1,) = ballot.voters(firstVoter);
        assertEq(voted1, true);
        assertEq(weight1, 1);
        assertEq(delegate1, secondVoter);
        (uint256 weight2, bool voted2, address delegate2,) = ballot.voters(secondVoter);
        assertEq(voted2, true);
        assertEq(weight2, 2);
        assertEq(delegate2, thirdVoter);
    }

    function test_circel_delegate() public {
        vm.prank(firstVoter);
        ballot.delegate(secondVoter);
        vm.prank(secondVoter);
        vm.expectRevert("Found loop in delegation.");
        ballot.delegate(firstVoter);
    }

    function test_vote() public {
        vm.startPrank(firstVoter);
        ballot.vote(0);
        vm.stopPrank();
        vm.startPrank(secondVoter);
        ballot.vote(1);
        vm.stopPrank();
        vm.startPrank(thirdVoter);
        ballot.vote(1);
        vm.stopPrank();

        (, uint256 voteCount1) = ballot.proposals(0);
        (, uint256 voteCount2) = ballot.proposals(1);

        assertEq(voteCount1, 1);
        assertEq(voteCount2, 2);

        uint256 proposalIndex = ballot.winningProposal();
        assertEq(proposalIndex, 1);

        bytes32 winnerName = ballot.winnerName();
        assertEq(bytes32(unicode"拒绝"), winnerName);
    }
}
