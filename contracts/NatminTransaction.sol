pragma solidity ^0.4.22;

import "./Ownable.sol";

contract EscrowWallet is Ownable{
	function transferTransactionAmounts(string _password) public returns (bool);
	function updateTransactionID(uint256 _transID) public returns (bool);
}

contract NatminTransaction is Ownable {
	using SafeMath for uint256;
	
	uint256 transactionID;

	struct TransactionDetails {
		address creator;
		address buyer;
		address seller;
		uint256 createTime;
		uint256 inspectionPeriod;
		string category;
		string description;		
	}

	struct TransactionStatus {
		bool buyerPaid;
		bool sellerSend;
		bool buyerReceived;
		bool completed;
	}

	struct TransactionFinance {		
		uint256	dollarAmount;
		uint256 tokenAmount;
		uint256 feePercentage; // Fee %
		uint256 sellerAmount;
		address escrowWalletAddress;
	}

	struct TransactionIDList {
		uint256[] ids;
	}

	// List of transactions created in the system
	mapping(uint256 => TransactionDetails) public transactionDetails; 
	mapping(uint256 => TransactionStatus) public transactionStatus;
	mapping(uint256 => TransactionFinance) public transactionFinance;

	// List of transaction IDs for each user 
	mapping(address => TransactionIDList) transactionIDLists;

	constructor() public {
		transactionID = 0;
	}

	function createTransactionID () private ownerOnly returns (uint256) {
		transactionID = transactionID.add(1);
		return transactionID;
	}

	function createTransaction(
		address _creator,
		address _buyer,
		address _seller,
		uint256 _inspectionPeriod,
		uint256 _dollarAmount,
		uint256 _tokenAmount,
		uint256 _feePercentage,		
		string _category,
		string _description,
		address _escrowWalletAddress) public returns (bool){

		// Requires the creator to be escrow wallet
		require(_creator != address(0));
		require(_buyer != address(0));
		require(_seller != address(0));
		require(_dollarAmount > 0);
		require(_tokenAmount > 0);
		require(_feePercentage > 0);
		require(_escrowWalletAddress != address(0));

		uint256 _transID = createTransactionID();

		transactionDetails[_transID].creator = _creator;
		transactionDetails[_transID].buyer = _buyer;
		transactionDetails[_transID].seller = _seller;
		transactionDetails[_transID].createTime = now;
		transactionDetails[_transID].inspectionPeriod = _inspectionPeriod;
		transactionDetails[_transID].category = _category;
		transactionDetails[_transID].description = _description;

		transactionFinance[_transID].dollarAmount = _dollarAmount;
		transactionFinance[_transID].tokenAmount = _tokenAmount;
		transactionFinance[_transID].feePercentage = _feePercentage;
		transactionFinance[_transID].sellerAmount = calculateSellerAmount(_tokenAmount,_feePercentage);
		transactionFinance[_transID].escrowWalletAddress = _escrowWalletAddress;

		transactionStatus[_transID].buyerPaid = false;
		transactionStatus[_transID].sellerSend = false;
		transactionStatus[_transID].buyerReceived = false;
		transactionStatus[_transID].completed = false;

		// Initiate the escrow wallet and update the transaction ID
		EscrowWallet _escrowWallet = EscrowWallet(_escrowWalletAddress);
		require(_escrowWallet.updateTransactionID(_transID));

		// Add the transaction IDs to the list for each user	
		createTransactionIDList(_seller,_transID);
		createTransactionIDList(_buyer,_transID);

		return true;
	}

	function getTransactionID() public view returns (uint256) {
		return transactionID;
	}

	// Adding transaction IDs to the list for the specified user
	function createTransactionIDList(address _user, uint256 _transactionID) internal ownerOnly {
		transactionIDLists[_user].ids.push(_transactionID);
	}

	// Returns the list of transaction IDs for a specified user
	function getTransactionIDList(address _user) public view ownerOnly returns (uint256[]) {
		return transactionIDLists[_user].ids;
	}

	// Update the transaction after the buyer has funded the transaction
	function updateTransactionBuyerPaid(uint256 _transID) public returns (bool) {
		require(transactionFinance[_transID].escrowWalletAddress == msg.sender);
		transactionStatus[_transID].buyerPaid = true;
		return true;
	}

	// Update the transaction after the seller confirms the items are sent
	function updateTransactionSellerSend(uint256 _transID) public ownerOnly returns (bool) {
		require(transactionStatus[_transID].buyerPaid == true);
		transactionStatus[_transID].sellerSend = true;
		return true;
	}

	// Update the transaction after buyer confirms th receipt of items
	function updateTransactionBuyerReceived(uint256 _transID) public ownerOnly returns (bool) {
		require(transactionStatus[_transID].buyerPaid == true);
		require(transactionStatus[_transID].sellerSend == true);
		require(transactionStatus[_transID].buyerReceived == false);

		transactionStatus[_transID].buyerReceived = true;
		return true;
	}

	// This will also complete the transaction and transfers the money to the seller 
	function updateTransactionCompleted(
		uint256 _transID, 
		string _password) public ownerOnly returns (bool) {
		require(transactionStatus[_transID].buyerPaid == true);
		require(transactionStatus[_transID].sellerSend == true);
		require(transactionStatus[_transID].buyerReceived == true);
		require(transactionStatus[_transID].completed == false);

		EscrowWallet _escrowWallet = EscrowWallet(transactionFinance[_transID].escrowWalletAddress);
		require(_escrowWallet.transferTransactionAmounts(_password));

		transactionStatus[_transID].completed = true;
		return true;
	}

	// Returns the transaction token amount
	function getTransactionAmount(uint256 _transID) public view returns (uint256) {
		return transactionFinance[_transID].tokenAmount;
	}

	// Returns the calculated seller token amount
	function getSellerAmount(uint256 _transID) public view returns (uint256) {
		return transactionFinance[_transID].sellerAmount;
	}

	// Returns the address of the buyer 
	function getTransactionBuyer(uint256 _transID) public view returns (address) {
		return transactionDetails[_transID].buyer;
	}

	// Returns the address of the seller 
	function getTransactionSeller(uint256 _transID) public view returns (address) {
		return transactionDetails[_transID].seller;
	}

	// Returns the status of buyerPaid
	function getTransactionBuyerPaid(uint256 _transID) public view returns (bool) {
		return transactionStatus[_transID].buyerPaid;
	}

	// Calculates and returns the seller amount.
	// Total token amount minus the fees
	function calculateSellerAmount(
		uint256 _tokenAmount, 
		uint256 _feePercentage) internal view ownerOnly returns (uint256) {

		uint256 _fees = _tokenAmount.mul(_feePercentage).div(100);
		return _tokenAmount.sub(_fees);
	}

	// Update the transaction with the nominated escrow wallet
	// Initiate the escrow wallet and update the transaction ID
	function updateEscrowWallet(uint256 _transID, address _escrowWalletAddress) public ownerOnly {
		transactionFinance[_transID].escrowWalletAddress = _escrowWalletAddress;		
		EscrowWallet _escrowWallet = EscrowWallet(_escrowWalletAddress);
		require(_escrowWallet.updateTransactionID(_transID));
	}
}