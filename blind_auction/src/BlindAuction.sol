// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;

    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    mapping(address => uint256) pendingReturns;

    event AuctionEnded(address winner, uint256 highestBid);

    error TooEarly(uint256 time);
    error TooLate(uint256 time);
    error AuctionEndAlreadyCalled();

    modifier onlyBefore(uint256 time) {
        if (block.timestamp >= time) {
            revert TooLate(time);
        }
        _;
    }

    modifier onlyAfter(uint256 time) {
        if (block.timestamp <= time) {
            revert TooEarly(time);
        }
        _;
    }

    constructor(uint256 biddingTime, uint256 revealTime, address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealEnd;
    }
}
