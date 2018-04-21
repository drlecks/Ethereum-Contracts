pragma solidity ^0.4.23;

import "./EIP20Interface.sol";
import "./BlockableContract.sol";


//test token 0xcae8cf129edf9c21451c47a1fefe2bec629f99b9

contract Hodl is BlockableContract{
    
    struct Safe{
        uint256 id;
        address user;
        address tokenAddress;
        uint256 amount;
        uint256 time;
    }
    
    mapping( address => uint256[]) public _userSafes;
    mapping( uint256 => Safe) private _safes;
    uint256 private _currentIndex;
    
    uint256 public comission; //0..100
    mapping( address => uint256) private _systemReserves;
    address[] public _listedReserves;
     
     
    constructor() public { 
        _currentIndex = 1;
        comission = 10;
    }
    
    function () public payable {
        require(msg.value>0);
        _systemReserves[0x0] += msg.value;
    }
    
    function GetUserSafesLength(address a) public view returns (uint256 length) {
        return _userSafes[a].length;
    }
    
    function Getsafe(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 time)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.time);
    }
    
    //ADD HODL
    function HodlEth(uint256 time) public payable {
        require(msg.value > 0);
        require(time>now);
        
        _userSafes[msg.sender].push(_currentIndex);
        _safes[_currentIndex] = Safe(_currentIndex, msg.sender, 0x0, msg.value, time); 
        
        _currentIndex++;
    }
    
    
    function ClaimHodlToken(address tokenAddress, uint256 amount, uint256 time) public {
        require(tokenAddress != 0x0);
        require(amount>0);
        require(time>now);
          
        EIP20Interface token = EIP20Interface(tokenAddress);
        require( token.transferFrom(msg.sender, address(this), amount) );
        
        _userSafes[msg.sender].push(_currentIndex);
        _safes[_currentIndex] = Safe(_currentIndex, msg.sender, tokenAddress, amount, time);
        
        _currentIndex++;
    }
    
    
    //GET HODL
    function RetireHodl(uint256 id) public {
        Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.user == msg.sender);
        
        if(s.time < now) //hodl complete
        {
            if(s.tokenAddress == 0x0) 
                PayEth(s.user, s.amount);
            else  
                PayToken(s.user, s.tokenAddress, s.amount);
        }
        else //hodl in progress
        {
            uint256 realComission = safeMultiply(s.amount, comission) / 100;
            uint256 realAmount = s.amount - realComission;
            
            if(s.tokenAddress == 0x0) 
                PayEth(s.user, realAmount);
            else  
                PayToken(s.user, s.tokenAddress, realAmount);
                
            StoreComission(s.tokenAddress, realComission);
        }
        
        DeleteSafe(s);
    }
    
    
    function PayEth(address user, uint256 amount) private {
        require(address(this).balance >= amount);
        user.transfer(amount);
    }
    

    function PayToken(address user, address tokenAddress, uint256 amount) private{
        EIP20Interface token = EIP20Interface(tokenAddress);
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
    }
    
    
    function StoreComission(address tokenAddress, uint256 amount) private {
        _systemReserves[tokenAddress] += amount;
        
        bool isNew = true;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            if(_listedReserves[i] == tokenAddress) {
                isNew = false;
                break;
            }
        } 
        
        if(isNew) _listedReserves.push(tokenAddress); 
    }
    
    
    function DeleteSafe(Safe s) private  {
        delete _safes[_currentIndex];
        
        uint256[] storage vector = _userSafes[msg.sender];
        uint256 size = vector.length; 
        for(uint256 i = 0; i < size; i++) {
            if(vector[i] == s.id) {
                vector[i] = vector[size-1];
                vector.length--;
                break;
            }
        } 
    }
    
    
    //OWNER
    function GetReserveAmount(address tokenAddress) public view returns (uint256 amount){
        return _systemReserves[tokenAddress];
    }
    
    
    function ChangeComission(uint256 newComission) onlyOwner public {
        comission = newComission;
    }
    
    
    function WithdrawReserve(address tokenAddress) onlyOwner public
    {
        require(_systemReserves[tokenAddress] > 0);
        
        uint256 amount = _systemReserves[tokenAddress];
        _systemReserves[tokenAddress] = 0;
        
        EIP20Interface token = EIP20Interface(tokenAddress);
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }
    
    
    function WithdrawAllReserves() onlyOwner public {
        //eth
        if(_systemReserves[0x0] > 0) {
             msg.sender.transfer( _systemReserves[0x0] );
             _systemReserves[0x0] = 0;
        }
         
        //tokens
        address ta;
        EIP20Interface token;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            ta = _listedReserves[i];
            if(_systemReserves[ta] > 0)
            { 
                uint256 amount = _systemReserves[ta];
                _systemReserves[ta] = 0;
                
                token = EIP20Interface(ta);
                token.transfer(msg.sender, amount);
            }
        } 
        
        _listedReserves.length = 0; 
    }
    
    
    function WithdrawSpecialEth(uint256 amount) onlyOwner public
    {
        require(amount > 0);
        require(address(this).balance >= amount); 
        
        msg.sender.transfer(amount);
    }
    
    
    function WithdrawSpecialEth(address tokenAddress, uint256 amount) onlyOwner public
    {
        require(_systemReserves[tokenAddress] > 0); 
        
        EIP20Interface token = EIP20Interface(tokenAddress);
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }
    
    
    //AUX
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
    
    
}