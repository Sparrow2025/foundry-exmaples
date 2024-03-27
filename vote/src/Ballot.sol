// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Ballot {
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }

    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    // external 只能在合约之外调用,不能被合约内的其它函数调用
    function giveRightToVote(address voter) external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        // 传引用
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no right to vote.");
        require(!sender.voted, "The voter already voted.");
        require(to != msg.sender, "Self-delegation is not allowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        // `sender`是一个引用,相当于对`voters[msg.sender].voted`进行修改
        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1);
        sender.voted = true;
        sender.delegate = to;
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint256 proposal) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningProposal_ = p;
            }
        }
    }

    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
