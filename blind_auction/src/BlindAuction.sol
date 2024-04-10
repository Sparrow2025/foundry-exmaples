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

    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(Bid({blindedBid: blindedBid, deposit: msg.value}));
    }

    function reveal(uint256[] calldata values, bool[] calldata fake, bytes32[] calldata secret)
        external
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint256 length = binds[msg.sender].length;
        require(values.length == length);
        require(fake.length == length);
        require(secret.length == length);

        uint256 refund;
        for (uint256 i = 0; i < length; i++) {
            Bid storage bid = bids[msg.sender][i];
            (uint256 value, bool fake, bytes32 secret) = (values[i], fake[i], secret[i]);
            if (bid.blindedBid != keccak256(value, fake, secret)) {
                // 出价未能正确披露
                // 不返回订金
                continue;
            }
            refund += bid.deposit;
            if (!fake && bid.deposit >= value) {
                if (placeBid(msg.sender, value)) {
                    refund -= value;
                }
            }
            bid.blindedBid = bytes32(0);
        }
        msg.sender.transfer(refund);
    }

    function placeBid(address bidder, uint256 value) internal returns (bool success) {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        heghestBidder = bidder;
        return true;
    }

    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }

    function auctionEnd() external onlyAfter(revealEnd) {
        if (ended) {
            revert AuctionAlreadyCalled();
        }
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(heghestBidder);
    }
}
