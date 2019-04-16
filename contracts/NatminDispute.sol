pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminDispute is Ownable {
	using SafeMath for uint256;
	
	GeneralContract settings;

	struct DisputeDetails {
		bool created;
		address buyer;
		address seller;
		string details;		
	}

	struct DisputeIDList {
		uint256[] ids;
	}

	// List of transactions created in the system
	mapping(uint256 => DisputeDetails) public disputeDetails; 

	// List of transaction IDs for each user 
	mapping(address => DisputeIDList) private disputeIDLists;

	constructor(address _generalContract) public {
		settings = GeneralContract(_generalContract);
	}

	function createDispute(
		uint256 _disputeID,
		address _buyer,
		address _seller,
		string _details) public ownerOnly returns (bool){

		require(_disputeID > 0);
		require(_buyer != address(0));
		require(_seller != address(0));
		require(bytes(_details).length > 0);
		require(disputeDetails[_disputeID].created == false);

		disputeDetails[_disputeID].created = true;
		disputeDetails[_disputeID].buyer = _buyer;
		disputeDetails[_disputeID].seller = _seller;
		disputeDetails[_disputeID].details = _details;

		// Add the transaction IDs to the list for each user	
		createDisputeIDList(_seller,_disputeID);
		createDisputeIDList(_buyer,_disputeID);

		return true;
	}

	// Adding transaction IDs to the list for the specified user
	function createDisputeIDList(address _user, uint256 _disputeID) internal ownerOnly {
		disputeIDLists[_user].ids.push(_disputeID);
	}

	// Returns the list of transaction IDs for a specified user
	function getDisputeIDList(address _user) public view ownerOnly returns (uint256[]) {
		return disputeIDLists[_user].ids;
	}

}