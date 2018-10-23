pragma solidity ^0.4.22;

import "./NatminToken.sol";

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