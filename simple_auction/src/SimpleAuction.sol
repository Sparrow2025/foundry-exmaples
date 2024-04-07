// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract SimpleAuction {
    address payable public beneficiary;

    uint256 public auctionEnd;

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    error AuctionAlreadyEnded();
    error BidNotHighEnough(uint256 highestBid);
    error AuctionNotYetEnded();
    error AuctionEndAlreadyCalled();

    constructor(uint256 biddingTime, address payable beneficiaryAddress) {
        beneficiaryAddress = beneficiaryAddress;
        auctionEnd = block.timestamp + biddingTime;
    }

    function bid() external payable {
        if (block.timestamp > auctionEnd) {
            revert AuctionAlreadyEnded();
        }
        if (msg.value <= highestBid) {
            revert BidNotHighEnough(highestBid);
        }
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionOver() external {
        if (block.timestamp < auctionEnd) {
            revert AuctionNotYetEnded();
        }
        if (ended) {
            revert AuctionEndAlreadyCalled();
        }

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}
