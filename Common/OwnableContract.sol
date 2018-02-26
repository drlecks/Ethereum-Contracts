pragma solidity ^0.4.20;
 

contract OwnableContract {
 
    address superOwner;
		
	function OwnableContract() public { 
        superOwner = msg.sender;  
    }
	
	modifier onlyOwner() {
        require(msg.sender == superOwner);
        _;
    } 
    
    function viewSuperOwner() public view returns (address owner) {
        return superOwner;
    }
    
	function changeOwner(address newOwner) onlyOwner public {
        superOwner = newOwner;
    }
}