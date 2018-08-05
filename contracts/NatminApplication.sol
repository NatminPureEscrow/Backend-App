pragma solidity ^0.4.22;

import "./NatminToken.sol";

contract NatminTransation is Ownable {
	using SafeMath for uint256;

	uint256 private	transactionID;
	
	struct Transaction {
		address creator;
		address buyer;
		address seller;
		uint256 createTime;
		uint256 endTime;
		uint256	dollarAmount;
		uint256 tokenAmount;
		//string shortDescription;
		string description;
		bool buyerPaid;
		bool sellerSend;
		bool buyerReceived;
		bool completed;
		uint256 gas;
	}

	struct TransactionIDList {
		uint256[] ids;
	}
	// List of transactions created in the system
	mapping(uint256 => Transaction) public transactions; 

	// List of transaction IDs for each user 
	mapping(address => TransactionIDList) transactionIDLists;

	constructor() public {
		transactionID = 0;
	}

	// Increment the transaction ID
	function createTransactionID() public returns (uint256) {
		transactionID = transactionID.add(1);
	}

	// Returns the current transaction ID
	function getTransactionID() public view returns (uint256) {
		return transactionID;
	}

	function createTransaction(
		address _buyer,
		address _seller,
		uint256 _endTime,
		uint256 _dollarAmount,
		uint256 _tokenAmount,		
		string _description,
		bool _buyerPaid) public ownerOnly {

		// Requires the creator to be contract owner
		require(_buyer != 0x0);
		require(_seller != 0x0);
		require(_endTime > 0); // Amount in days
		require(_dollarAmount > 0);
		require(_tokenAmount > 0);
		//require(bytes(_shortDescription).length > 0);
		require(bytes(_description).length > 0);

		address _creator = msg.sender;

		// Create and return the transaction ID to be used for this transaction.
		createTransactionID();
		uint256 _transID = getTransactionID();
		
		transactions[_transID].creator = _creator;
		transactions[_transID].buyer = _buyer;
		transactions[_transID].seller = _seller;
		transactions[_transID].createTime = now;
		transactions[_transID].endTime = _endTime;
		transactions[_transID].dollarAmount = _dollarAmount;
		transactions[_transID].tokenAmount = _tokenAmount;
	    //transactions[_transID].shortDescription = _shortDescription;
		transactions[_transID].description = _description;		
		transactions[_transID].buyerPaid = _buyerPaid;
		transactions[_transID].sellerSend = false;
		transactions[_transID].buyerReceived = false;
		transactions[_transID].completed = false;
		transactions[_transID].gas = 0;

		// Add the transaction IDs to the list for each user	
		createTransactionIDList(_seller,_transID);
		createTransactionIDList(_buyer,_transID);
	}

	// Adding transaction IDs to the list for the specified user
	function createTransactionIDList(address _user, uint256 _transactionID) internal {
		transactionIDLists[_user].ids.push(_transactionID);
	}

	// Returns the list of transaction IDs for a specified user
	function getTransactionIDList(address _user) public view returns (uint256[]) {
		return transactionIDLists[_user].ids;
	}

	// Update the calculated gas for each transaction interaction
	function updateTransactionGas(uint256 _transID, uint256 _calculatedGas) public {
		transactions[_transID].gas = transactions[_transID].gas.add(_calculatedGas);
	}

	function updateTransactionBuyerPaid(uint256 _transID) public ownerOnly {
		transactions[_transID].buyerPaid = true;
	}

	function updateTransactionSellerSend(uint256 _transID) public ownerOnly {
		transactions[_transID].sellerSend = true;
	}

	function updateTransactionBuyerReceived(uint256 _transID) public ownerOnly {
		transactions[_transID].buyerReceived = true;
	}

	function updateTransactionCompleted(uint256 _transID) public ownerOnly {
		transactions[_transID].completed = true;
	}
}


contract NatminDispute is Ownable {
	using SafeMath for uint256;

	uint256 private disputeID;
	NatminVote internal Votes;

	struct Dispute {
		uint256 transactionID;		
		address creator;		
		address buyer;
		address seller;	
		uint256 createTime;
		uint256 endTime;
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

	constructor(NatminVote _natminVoteContract) public {
		disputeID = 0;
		Votes = _natminVoteContract;
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
		address _buyer,
		address _seller,
		string 	_description) public ownerOnly {

		require(_transactionID > 0);
		require(_buyer != 0x0);
		require(_seller != 0x0);		
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
		disputes[_disputeID].endTime = now + 7 days;
		disputes[_disputeID].resolved = false;
		disputes[_disputeID].voteCount = 0;		
		disputes[_disputeID].firstVoteID = _firstVoteID;
		disputes[_disputeID].secondVoteID = _SecondVoteID;

		// Adding the dispute ID to the list for each user
		createDisputeIDList(_buyer, _disputeID);
		createDisputeIDList(_seller, _disputeID);
	}

}

contract NatminVote is Ownable {
	using SafeMath for uint256;

	uint256 public voteID;

	mapping(uint256 => uint256) public voteCount;

	constructor () public {
		voteID = 0;
	}

	// List of votes cast for each dispute
	mapping(uint256 => mapping(address => bool)) public votes;

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
		require(voteCount[_voteID] < 5);		
		votes[_voteID][_user] = _vote;
		increaseVoteCount(_voteID);
	}

	// Returns the vote cast for a specified user and transaction 
	function getVote(uint256 _voteID, address _user) public view returns (bool) {
		return votes[_voteID][_user];
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

contract NatminUsers is Ownable {
	using SafeMath for uint256;

	mapping(bytes32 => address) public users;

	function updateUserAddress(bytes32 _email, address _address) public  ownerOnly {
		users[_email] = _address;
	}

	function getUserAddress(bytes32 _email) public ownerOnly view returns (address) {
		return users[_email];
	}
}