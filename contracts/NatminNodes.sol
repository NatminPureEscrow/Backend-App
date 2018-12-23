pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract NatminNodes is Ownable {
	using SafeMath for uint256;

	uint256 MinStake;
	GeneralContract settings;

	struct NodeDetail {
		string category;
		uint256 stake;
		bool blacklist;
		uint256 pointsReceived;
		uint256 pointsLost;
	}
	// Category => (Node => NodeDetails)
	mapping(address => NodeDetail) public Nodes;


	constructor (address _generalContract) public {		
		MinStake = 10000 * (10 ** 18); // Min stake amount of 10,000 NAT
		settings = GeneralContract(_generalContract);
	}

	// Updates the Minimum stake amount
	function updateMinStake(uint256 _newMinStake) public ownerOnly {
		require(_newMinStake > MinStake);		
		MinStake = _newMinStake;
	}

	// Creates a new Node details or updates
	function createNode(string _category, address _nodeAddress, uint256 _stake) public ownerOnly {
		require(bytes(_category).length > 0); // Category char length must be larger than 0
		require(_nodeAddress != 0x0); // Adddress must not be address 0
		require(_stake >= MinStake); //The stake amount must the larger than min take
		require(Nodes[_nodeAddress].blacklist != true); // Prevents the creation of a blacklisted address
		
		address _tokenAddress = settings.getSettingAddress('TokenContract');
		ERC20Standard _token = ERC20Standard(_tokenAddress);
		require(_token.balanceOf(_nodeAddress) >= _stake); // Requries the current balance to be greater than stake
		
		Nodes[_nodeAddress].category = _category;
		Nodes[_nodeAddress].stake = _stake;
		Nodes[_nodeAddress].blacklist = false;
		Nodes[_nodeAddress].pointsReceived = 0;
		Nodes[_nodeAddress].pointsLost = 0;
	}

	// Add 2 points for for reach correct vote
	// This can only be updated from the dispute contract 
	function addPoints(address _nodeAddress) public returns (bool) {
		//require(msg.sender == settings.getSettingAddress('DisputeContract'));
		Nodes[_nodeAddress].pointsReceived = Nodes[_nodeAddress].pointsReceived.add(2);
		return true;
	}

	// Removes 1 point for for reach incorrect vote
	// This can only be updated from the dispute contract 
	function removePoints(address _nodeAddress) public returns (bool) {
		//require(msg.sender == settings.getSettingAddress('DisputeContract'));
		Nodes[_nodeAddress].pointsLost = Nodes[_nodeAddress].pointsLost.add(1);
		if(Nodes[_nodeAddress].pointsLost >= 3){
			Nodes[_nodeAddress].blacklist = true;
		}
		return true;
	}

	// Updates the stake amount of the specified Node
	function updateNodeStake(address _nodeAddress, uint256 _stake) public ownerOnly returns (bool) {
		require(Nodes[_nodeAddress].blacklist != true);
		require(Nodes[_nodeAddress].stake >= MinStake);  // Required to be set on Node creation
		require(_stake > Nodes[_nodeAddress].stake); // Can only be set if new stake is larger than old
		Nodes[_nodeAddress].stake = _stake;

		return true;
	}
}