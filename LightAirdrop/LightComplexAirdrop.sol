pragma solidity ^0.4.21;

import "./EIP20Interface.sol";
import "./ComplexToken.sol";
import "./OwnableContract.sol";

contract LightComplexAirdrop is OwnableContract{ 
      
    function LightComplexAirdrop() public { 
    }
     
    function performEqual(address tokenAddress, address[] tos, uint256 amount) onlyOwner public { 
        ComplexToken tokenContract = ComplexToken(tokenAddress); 
        tokenContract.transferMulti(tos, amount);
    }
    
    function performDifferent(address tokenAddress, address[] tos, uint256[] amounts) onlyOwner public {
        ComplexToken tokenContract = ComplexToken(tokenAddress); 
        tokenContract.transferMultiDiff(tos, amounts);
    }
    
    function withdraw(address tokenAddress) onlyOwner public { 
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this))); 
    }
}