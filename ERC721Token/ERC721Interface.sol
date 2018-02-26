/*
* @title ERC721 interface
*/

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event Approval(address indexed _owner, address indexed _operator, uint256 _tokenId);
    
    /**
    * @dev Gets the total amount of allocated tokens
    * @return uint256 representing the total amount of allocated tokens
    */
    function totalSupply() public view returns (uint256);
    
    /**
    * @dev Gets the balance of the specified address
    * @param _owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address _owner) public view returns (uint256 _balance);
    
    /**
    * @dev Gets the owner of the specified token ID
    * @param _tokenId uint256 ID of the token to query the owner of
    * @return owner address currently marked as the owner of the given token ID
    */
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    
    /**
    * @dev Transfers the ownership of a given token ID from one address to another address
    * @param _to address to receive the ownership of the given token ID
    * @param _from address of the current owner of the token ID will be sent from
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    
    /**
    * @dev Transfers the ownership of a given token ID from one address to another address
    * This transfer is a safe transfer and calls onAssetReceived on the receiving address passing
    * in the supplied data. 
    * function onAssetReceived(
    *  // address _erc721 == msg.sender 
    *   address _from,
    *   uint256 _tokenId,
    *   bytes   _data
    * )
    * @param _to address to receive the ownership of the given token ID
    * @param _from address of the current owner of the token ID will be sent from
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _tokenId, bytes data) public;
    
    /**
    * @dev Check whether the operator address is allowed to manage all of the tokens held by the tokenHolder address.
    * @param _operator address to check if it has the right to manage the tokens
    * @param _owner address of a token holder
    * @return true if the operator has management over the token holders tokens
    */
    function isApproved(address _operator, address _owner) public constant returns (bool);
    
    /**
    * @dev Check whether the operator address is allowed to manage the _tokenId held by the tokenHolder address.
    * @param _operator address to check if it has the right to manage the tokens
    * @param _owner address of a token holder
    * @return true if the operator has management over the token holders tokens
    */
    function isApproved(address _operator, address _owner, uint256 _tokenId) public constant returns (bool);
    
    /**
    * @dev Approve a third party (operator) to manage a single _tokenId. 
    * There may only be one approved operator for any single tokenId.
    * All subsequent approves on the same _tokenId reset the previous.
    * To revoke the operator for this tokenId, set the address to 0.
    * This emits an Approval event.
    * @param _operator address to add to the set of authorized operators for _tokenId.
    * @param _approved boolean true if the operators is approved for _tokenId, false to revoke approval.
    */
    function approve(address _operator, uint256 _tokenId) public;
    
    /**
    * @dev Approve a third party (operator) to to manage all of (send) msg.sender's tokens. 
    * To revoke this approval call this function with false on the operator 
    * This emits an ApprovalForAll event.
    * @param _operator address to add to the set of authorized operators.
    * @param _approved boolean true if the operators is approved, false to revoke approval.
    */
    function setApprovalForAll(address _operator, boolean _approved) public;
    
    /**
    * @dev Returns `true` if the contract implements `interfaceID` and`interfaceID` is not 0xffffffff, `false` otherwise
    * @param  interfaceID The interface identifier, as specified in ERC-165
    */
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}