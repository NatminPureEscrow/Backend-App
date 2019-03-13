pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminTransaction is Ownable {
	using SafeMath for uint256;
	
	GeneralContract settings;

	struct TransactionDetails {
		bool created;
		address buyer;
		address seller;
		string details;		
	}

	struct TransactionIDList {
		uint256[] ids;
	}

	// List of transactions created in the system
	mapping(uint256 => TransactionDetails) public transactionDetails; 

	// List of transaction IDs for each user 
	mapping(address => TransactionIDList) private transactionIDLists;

	constructor(address _generalContract) public {
		settings = GeneralContract(_generalContract);
	}

	function createTransaction(
		uint256 _transID,
		address _buyer,
		address _seller,
		string _details) public returns (bool){

		require(_transID > 0);
		require(_buyer != address(0));
		require(_seller != address(0));
		require(bytes(_details).length > 0);
		require(transactionDetails[_transID].created == false);

		transactionDetails[_transID].created = true;
		transactionDetails[_transID].buyer = _buyer;
		transactionDetails[_transID].seller = _seller;
		transactionDetails[_transID].details = _details;

		// Add the transaction IDs to the list for each user	
		createTransactionIDList(_seller,_transID);
		createTransactionIDList(_buyer,_transID);

		return true;
	}

	// Adding transaction IDs to the list for the specified user
	function createTransactionIDList(address _user, uint256 _transactionID) internal ownerOnly {
		transactionIDLists[_user].ids.push(_transactionID);
	}

	// Returns the list of transaction IDs for a specified user
	function getTransactionIDList(address _user) public view ownerOnly returns (uint256[]) {
		return transactionIDLists[_user].ids;
	}

}