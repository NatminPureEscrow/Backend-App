pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract EscrowWallet {
	function transfer(address _to, uint256 _amount) public returns (bool);
}

contract NatminTransaction is Ownable {
	using SafeMath for uint256;
	
	uint256 transactionID;
	GeneralContract settings;

	struct TransactionDetails {
		address creator;
		address buyer;
		address seller;
		uint256 createTime;
		string category;
		string description;		
	}

	struct TransactionStatus {
		bool dispute;
		uint256 disputeID;
		bool completed;
	}

	struct TransactionFinance {		
		uint256	dollarAmount;
		uint256 tokenAmount;
		uint256 buyerAmount;
		uint256 sellerAmount;
		uint256 systemAmount;
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

	constructor(address _generalContract) public {
		transactionID = 0;
		settings = GeneralContract(_generalContract);
	}

	function createTransactionID () private ownerOnly returns (uint256) {
		transactionID = transactionID.add(1);
		return transactionID;
	}

	function createTransaction(
		address _creator,
		address _buyer,
		address _seller,
		uint256 _createTime,
		uint256 _dollarAmount,
		uint256 _tokenAmount,
		uint256 _buyerAmount,		
		uint256 _sellerAmount,
		uint256 _systemAmount,
		uint256 _dispute,
		uint256 _disputeID,
		string _category,
		string _description,
		address _escrowWalletAddress) public returns (bool){

		// Requires the creator to be escrow wallet
		
		require(_buyer != address(0));
		require(_seller != address(0));
		require(_createTime > 0);
		require(_dollarAmount > 0);
		require(_tokenAmount > 0);
		require(_buyerAmount > 0);
		require(_sellerAmount > 0);
		require(_systemAmount > 0);
		require(bytes(_category).length > 0);
		require(bytes(_description).length > 0);
		require(_escrowWalletAddress != address(0));

		uint256 _transID = createTransactionID();

		transactionDetails[_transID].creator = _creator;
		transactionDetails[_transID].buyer = _buyer;
		transactionDetails[_transID].seller = _seller;
		transactionDetails[_transID].createTime = _createTime;
		transactionDetails[_transID].category = _category;
		transactionDetails[_transID].description = _description;

		transactionFinance[_transID].dollarAmount = _dollarAmount;
		transactionFinance[_transID].tokenAmount = _tokenAmount;
		transactionFinance[_transID].buyerAmount = _buyerAmount;
		transactionFinance[_transID].sellerAmount = _sellerAmount;
		transactionFinance[_transID].systemAmount = _systemAmount;
		transactionFinance[_transID].escrowWalletAddress = _escrowWalletAddress;

		if(_dispute == 1) {
			transactionStatus[_transID].dispute = true;
		} else {
			transactionStatus[_transID].dispute = false;
		}
        
		transactionStatus[_transID].disputeID = _disputeID;
		transactionStatus[_transID].completed = true;

		// Add the transaction IDs to the list for each user	
		createTransactionIDList(_seller,_transID);
		createTransactionIDList(_buyer,_transID);

		transferPayments(_transID);

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


	// This will also complete the transaction and transfers the money to the seller 
	function transferPayments(uint256 _transID) public ownerOnly returns (bool) {
		if(transactionStatus[_transID].dispute == false){
			// Transfers the required amount for each party
			EscrowWallet _escrowWallet = EscrowWallet(transactionFinance[_transID].escrowWalletAddress);
			address _systemWallet = settings.getSettingAddress('SystemWallet');
			require(_escrowWallet.transfer(transactionDetails[_transID].buyer,transactionFinance[_transID].buyerAmount));
			require(_escrowWallet.transfer(transactionDetails[_transID].seller,transactionFinance[_transID].sellerAmount));
			require(_escrowWallet.transfer(_systemWallet,transactionFinance[_transID].systemAmount));			
		}		

		return true;
	}

}