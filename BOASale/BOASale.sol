pragma solidity ^0.4.20;


import "./EIP20Interface.sol";
import "./BlockableContract.sol";


//to create contract user this initialization
//"0x000000000000000000000000token"

//from token contract, send tokens to this contract. in remix use this like:
//"0x000000000000000000000000address", "50000000000000000000000000" 


contract BOASale is BlockableContract { 
    
    EIP20Interface public tokenContract;  // the token being sold
    
    
    uint256 public freeAmount;
    uint256 public remainingFree; 
    mapping (address => bool) private receivedDonation;
    
    uint256[] public saleMilestones;
    uint256 public remainingSale;
    address[] public tokenHolders;
    mapping (address => uint256) private purchasedAmount;
    
    
    event Sold(address buyer, uint256 amount);
    event Airdroped(address buyer, uint256 amount);
 
 
    function BOASale(EIP20Interface _tokenContract) public { 
        tokenContract = _tokenContract;  
        
        saleMilestones = new uint256[](3);
        saleMilestones[0] = 20000000 ether;
        saleMilestones[1] = 10000000 ether;
        saleMilestones[2] = 5000000 ether; 
        
        remainingFree = 20000000 ether; 
        freeAmount = 69000 ether;
        
        remainingSale = 30000000 ether;
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
      
    function etherToToken(uint256 etherInWei) public view returns(uint256 tokenAmount)
    {
        uint256 baseChange = 10000; 
        if(remainingSale > saleMilestones[0]) baseChange = 100000; // 1 ether 100,000 tokens
        else if(remainingSale > saleMilestones[1]) baseChange = 50000; // 1 ether 50,000 tokens
        else if(remainingSale > saleMilestones[2]) baseChange = 25000; // 1 ether 25,000 tokens
        else baseChange = 10000; // 1 ether 10,000 tokens
        
        return safeMultiply(etherInWei , baseChange);
    }
    
    function() public payable {    
        if(! !blockedContract && remainingSale > 0) buyTokens();
    } 
    
    function buyTokens() contractActive saleActive public payable {  
        uint256 amount = etherToToken(msg.value); 
        
        require(amount <= tokenContract.balanceOf(this));
        require(amount <= remainingSale);
            
        emit Sold(msg.sender, amount);
        
        remainingSale -= amount;
        require(tokenContract.transfer(msg.sender, amount));
        
        purchasedAmount[msg.sender] += msg.value;
        tokenHolders.push(msg.sender);
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
        
        emit Airdroped(msg.sender, free);
        
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
        emit Airdroped(_to, realAmount); 
        
        require(tokenContract.transfer(_to, realAmount));
    }
    
    
    function ownerSale(address _to, uint256 amount) contractActive onlyOwner public {  
        uint256 realAmount;
        if(amount<=remainingSale) 
			realAmount = amount;
        else                      
			realAmount = remainingSale;
          
        remainingSale -= realAmount;  
        emit Sold(_to, realAmount); 
        
        require(tokenContract.transfer(_to, realAmount));
    }
    
	
    function withdraw(uint256 amount) onlyOwner public {
        require(address(this).balance >= amount);
        superOwner.transfer(amount);
    }
    
    function endSale() onlyOwner public { 
        //get all eth in the contract 
        withdraw(address(this).balance);
        
        // Send unsold tokens to the owner.
        require(tokenContract.transfer(superOwner, tokenContract.balanceOf(this)));

        // Destroy this contract, sending all collected ether to the owner.
        selfdestruct(superOwner);
    }
    
    function returnPurchasedEther() onlyOwner public {
        uint256 amount = 0;
        for(uint256 i=0; i<tokenHolders.length; i++) {
            amount = purchasedAmount[tokenHolders[i]];
            require(amount > 0 && address(this).balance >= amount);
            
            purchasedAmount[tokenHolders[i]] = 0;
            tokenHolders[i].transfer(amount);
        }
    }
}