pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminVote is Ownable {
	using SafeMath for uint256;

	GeneralContract settings;

	struct VoteDetail {
		bool created;
		string details;
	}

	// List of votes cast for each dispute
	mapping(uint256 => VoteDetail) public votes;

	constructor (address _generalContract) public {
		settings = GeneralContract(_generalContract);
	}	


	// Create a vote in the vote list
	function createVote(
		uint256 _disputeID,
		string _details) public ownerOnly returns (bool) {

		require(votes[_disputeID].created == false);

		votes[_disputeID].created = true;
		votes[_disputeID].details = _details;		

		return true;
	}
}