pragma solidity ^0.4.22;

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