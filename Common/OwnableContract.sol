pragma solidity ^0.4.20;
 

contract OwnableContract {
 
    address superOwner;
		
	function BlockableContract() public { 
        superOwner = msg.sender;  
    }
	
	modifier onlyOwner() {
        require(msg.sender == superOwner);
        _;
    } 
    
	function changeOwner(address newOwner) onlyOwner public {
        superOwner = newOwner;
    }
}