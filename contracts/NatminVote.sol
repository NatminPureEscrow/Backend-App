pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminVote is Ownable {
	using SafeMath for uint256;

	uint256 public voteID;
	GeneralContract settings;

	struct NodeGroup {

		Vote1
	}

	struct VoteDetail {
		bool created;
		uint256 date;
		uint256 yes;
		uint256 no;
		bool voteResult;
		
	}

	struct VoteCount {
		
	}

	// Keeps a mapping of the vote count for each vote ID 
	mapping(uint256 => VoteCount[]) public voteCount;

	// List of votes cast for each dispute
	mapping(uint256 => VoteDetail[]) public votes;

	constructor (address _generalContract) public {
		voteID = 0;
		settings = GeneralContract(_generalContract);
	}	

	// Increment the current vote ID
	function createVoteID () public {
		voteID = voteID.add(1);
	}

	// Returns the current vote ID
	function getVoteID () public view returns (uint256) {
		return voteID;
	}

	// Create a vote in the vote list
	function createVote(uint256 _voteID, address _user, bool _vote) public {
		
	}

	// Returns the vote cast for a specified user and transaction 
	function getVote(uint256 _voteID, address _user) public view returns (bool) {
		//return votes[_voteID][_user];
	}

	// Increased the vote count for a specified vote upto a count of 5
	function increaseVoteCount(uint256 _voteID) public {
		require(voteCount[_voteID] < 5);
		voteCount[_voteID] = voteCount[_voteID].add(1);
	}

	// Returns the current vote count for a specified vote ID
	function getVoteCount(uint256 _voteID) public view returns (uint256) {
		return voteCount[_voteID];
	}
}