pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminDispute is Ownable {
	using SafeMath for uint256;

	uint256 private disputeID;
	GeneralContract settings;

	struct Dispute {
		uint256 transactionID;		
		address creator;		
		uint256 createTime;
		string 	description;
		bool 	resolved;
		uint256 firstVoteID;
		uint256 secondVoteID;
		uint256	voteCount;
	}

	struct DisputeIDList {
		uint256[] ids;
	}

	// List of despute details created in the system
	mapping(uint256 => Dispute) public disputes;

	// List of disputes for each user
	mapping(address => DisputeIDList) private disputesIDLists;

	constructor(address _generalContract) public {
		disputeID = 0;
		settings = GeneralContract(_generalContract);
	}

	// Increment the dispute ID
	function createDisputeID() public {
		disputeID = disputeID.add(1);
	}

	// Returns the current dispute ID
	function getDisputeID() public view returns (uint256) {
		return disputeID;
	}

	// Adding the dispute IDs to the list for the specified user
	function createDisputeIDList(address _user, uint256 _disputeID) internal {
		disputesIDLists[_user].ids.push(_disputeID);
	}

	// Getting the list of dispute IDs for a specified user
	function getDisputeIDList(address _user) public view returns(uint256[]) {
		return disputesIDLists[_user].ids;
	}

	function createDispute(
		uint256 _transactionID,
		address _creator,
		string 	_description) public ownerOnly {

		require(_transactionID > 0);
		require(_creator != 0x0);		
		require(bytes(_description).length > 0);

		// Create dispute ID for the current dispute
		createDisputeID();

		Votes.createVoteID();
		uint256 _firstVoteID = Votes.getVoteID();
		Votes.createVoteID();		
		uint256 _SecondVoteID = Votes.getVoteID();
		
		// Getting the current dispute ID and create the dispute
		uint256 _disputeID = getDisputeID();
		disputes[_disputeID].transactionID = _transactionID;
		disputes[_disputeID].creator = msg.sender;
		disputes[_disputeID].buyer = _buyer;
		disputes[_disputeID].seller = _seller;
		disputes[_disputeID].createTime = now;
		disputes[_disputeID].resolved = false;
		disputes[_disputeID].voteCount = 0;		
		disputes[_disputeID].firstVoteID = _firstVoteID;
		disputes[_disputeID].secondVoteID = _SecondVoteID;

		// Adding the dispute ID to the list for each user
		createDisputeIDList(_buyer, _disputeID);
		createDisputeIDList(_seller, _disputeID);
	}

}
