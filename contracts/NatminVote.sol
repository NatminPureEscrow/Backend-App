pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminVote is Ownable {
	using SafeMath for uint256;

	GeneralContract settings;

	struct VoteDetail {
		bool created;
		bool voteResult;		
	}

	// List of votes cast for each dispute
	mapping(uint256 => mapping(address => VoteDetail)) public votes;

	mapping(uint256 => uint256) public voteCount;

	constructor (address _generalContract) public {
		settings = GeneralContract(_generalContract);
	}	


	// Create a vote in the vote list
	function createVote(
		uint256 _disputeID, 
		address _nodeAddress, 
		uint256 _voteResult,
		uint256 _paymentDue,
		uint256 _tokenAmount) public ownerOnly returns (bool) {

		require(votes[_disputeID][_nodeAddress].created == false);
		require(voteCount[_disputeID] < 5);

		votes[_disputeID][_nodeAddress].created = true;
		
		if(_voteResult == 1) {
			votes[_disputeID][_nodeAddress].voteResult = true;
		} else {
			votes[_disputeID][_nodeAddress].voteResult = false;
		}

		voteCount[_disputeID] = voteCount[_disputeID].add(1);

		if(_paymentDue == 1) {
			require(payNode(_nodeAddress, _tokenAmount));
		}

		return true;
	}

	function payNode(address _nodeAddress, uint256 _tokenAmount) internal ownerOnly returns (bool) {
		address _tokenAddress = settings.getSettingAddress('TokenContract');
		ERC20Standard _tokenContract = ERC20Standard(_tokenAddress);
		require(_tokenContract.transfer(_nodeAddress, _tokenAmount));

		return true;
	}
}