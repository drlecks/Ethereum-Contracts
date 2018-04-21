pragma solidity ^0.4.23;
 

import "./OwnableContract.sol";


contract BlockableContract is OwnableContract{
 
    bool public blockedContract;
	
	constructor() public { 
        blockedContract = false;  
    }
	
	modifier contractActive() {
        require(!blockedContract);
        _;
    } 
	
	function doBlockContract() onlyOwner public {
        blockedContract = true;
    }
    
    function unBlockContract() onlyOwner public {
        blockedContract = false;
    }
}