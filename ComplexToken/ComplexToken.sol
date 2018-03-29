/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/issues/20
.*/
pragma solidity ^0.4.21;

import "./EIP20Interface.sol"; 
import "./SafeMath.sol"; 

contract ComplexToken is EIP20Interface{

    using SafeMath for uint;
    
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) public allowed;
       
    string public name;                             //fancy name: eg Alex Cabrera 
    string public symbol;                           //An identifier: eg ACG
    
    
    event TransferMulti(address indexed _from, uint256 _value); 
    event TransferMultiDiff(address indexed _from); 
    
     
    function EIP20Token() public {  
        name = "ComplexToken";                              // Set the name for display purposes
        decimals = 18;                                      // Amount of decimals for display purposes
        symbol = "CTT";                                     // Set the symbol for display purposes
          
        totalSupply = 100000000;
        totalSupply = totalSupply.mul(10 ** decimals);      // Update total supply
        balances[msg.sender] = totalSupply;                 // Give the creator all initial tokens 
    } 
     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   
    
    /* COMPLEX TOKEN */
    
    /**
     * @dev transfers the same amount of tokens to several addresses.
     *
     * @param _tos   The address array to send the tokens
     * @return _value the amount of tokens to send to all addresses
     */
    function transferMulti(address[] _tos, uint256 _value) public returns (bool success) { 
        uint256 n = _tos.length; 
        uint256 total = _value.mul(n); 
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(total);
        
        uint256 i = 0; 
        for( ; i<n; i++) { 
            balances[_tos[i]] = balances[_tos[i]].add(_value);
        }
         
        emit TransferMulti(msg.sender, total);
        return true;
    }

    /**
     * @dev transfers tokens to several addresses, each with it's own amount
     *
     * @param _tos   The address array to send the tokens
     * @return _value the amount of tokens to send to each address
     */
	function transferMultiDiff(address[] _tos, uint256[] _values) public returns (bool success) { 
        uint256 n = _tos.length;  
          
        uint256 i = 0; 
        for( ; i<n; i++) { 
            require(balances[msg.sender] >= _values[i]);
            balances[msg.sender] = balances[msg.sender].sub(_values[i]);
            balances[_tos[i]] = balances[_tos[i]].add(_values[i]);
        }
         
        emit TransferMultiDiff(msg.sender);
        return true;
    }
}
