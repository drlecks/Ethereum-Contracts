pragma solidity ^0.4.21;


import "./EIP20Interface.sol";
import "./OwnableContract.sol";

contract LightAirdrop is OwnableContract{ 
     
 
    function LightAirdrop() public { 
    }
     
    function performEqual(address tokenAddress, address[] tos, uint256 amount) onlyOwner public {
        
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        
        uint256 i = 0;
        uint256 n = tos.length;
        for( ; i<n; i++) {
            tokenContract.transfer(tos[i], amount);
        }
    }
    
    function performDifferent(address tokenAddress, address[] tos, uint256[] amounts) onlyOwner public {
        
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        
        uint256 i = 0;
        uint256 n = tos.length;
        for( ; i<n; i++) {
            tokenContract.transfer(tos[i], amounts[i]);
        }
    }
    
    function withdraw(address tokenAddress) onlyOwner public { 
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this))); 
    }
}