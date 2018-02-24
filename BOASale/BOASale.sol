pragma solidity ^0.4.20;


import "./EIP20Interface.sol";
import "./BlockableContract.sol";

contract BOASale is BlockableContract {
    
    EIP20Interface public tokenContract;  // the token being sold
     
    uint256 public remainingSale;
    uint256 public remainingFree; 
    uint256 public freeAmount;
    uint256 public etherToToken;
     
    mapping (address => bool) private receivedDonation;
      
    event Sold(address buyer, uint256 amount);
    event Airdroped(address buyer, uint256 amount);
 
 
    function BOASale(EIP20Interface _tokenContract) public { 
        tokenContract = _tokenContract;  
           
        remainingFree = 2500000 ether; 
        freeAmount = 6900 ether;
        
        remainingSale = 2500000 ether; 
        etherToToken = 9600; // 1 ether 9,600 tokens
    }
      
    modifier airdropActive() {
        require(remainingFree > 0);
        _;
    } 
     
    modifier saleActive() {
        require(remainingSale > 0);
        _;
    } 
     
    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
     
    function() public payable {    
        if(! !blockedContract && remainingSale > 0) buyTokens();
    }
    
    
    function buyTokens() contractActive saleActive public payable {
        uint256 visibleAmount = safeMultiply(msg.value , etherToToken);
        uint256 scaledAmount = safeMultiply(visibleAmount, uint256(10) ** tokenContract.decimals());
        
        require(scaledAmount <= tokenContract.balanceOf(this));
        require(scaledAmount <= remainingSale);
            
        Sold(msg.sender, visibleAmount);
        
        remainingSale -= scaledAmount;
        require(tokenContract.transfer(msg.sender, scaledAmount));
    }
    
    
    function airdrop( ) contractActive airdropActive public { 
        require( receivedDonation[msg.sender] == false);
        
        uint256 free;
        if(freeAmount > remainingFree)  
			free = remainingFree;
        else                            
			free = freeAmount;
         
        remainingFree -= free;
        receivedDonation[msg.sender] = true;
        
        Airdroped(msg.sender, free);
        
        require(tokenContract.transfer(msg.sender, free));
    }
    
    function hasAirdrop(address who) public view returns (bool hasFreeTokens) { 
        hasFreeTokens =  receivedDonation[who];
        return hasFreeTokens;
    }
    
    function ownerAirdrop(address _to, uint256 amount) contractActive onlyOwner public {  
        uint256 realAmount;
        if(amount<=remainingFree) 
			realAmount = amount;
        else                      
			realAmount = remainingFree;
          
        remainingFree -= realAmount;  
        Airdroped(_to, realAmount); 
        
        require(tokenContract.transfer(_to, realAmount));
    }
	
    function withdraw(uint256 amount) onlyOwner public {
        require(this.balance >= amount);
        superOwner.transfer(amount);
    }
    
    function endSale() public {
        require(msg.sender == superOwner);

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(superOwner, tokenContract.balanceOf(this)));

        // Destroy this contract, sending all collected ether to the owner.
        selfdestruct(superOwner);
    }
}