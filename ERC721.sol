//SPDX-License-Identifier: UNLICENSED
//https://eips.ethereum.org/ Documentation
pragma solidity ^0.8.9;

import "./ERC165.sol";
import "./lib/Counters.sol";

interface IERC721 {
    
    event Approval (
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenID
    );

    event Transfer (
        address indexed from,
        address indexed to,
        uint256 indexed tokenID
    );

    function balanceOf(address _owner) external view returns(uint256);

    function ownerOf(uint256 _tokenID) external view returns(address);

    function transferFrom(address _from, address _to, uint256 _tokenID) external;

}

contract ERC721 is IERC721, ERC165 {
    /*
    
    TO CREATE AN NFT WE FISRT NEED:
        -ERC721 POITING SOMEWHERE
        -MANAGE ID REGISTRATION FOR TOKENS
        -HANDLE OWNER REGISTRATION (WALLET)
        -TOKENS PER WALLET
        -CREATE A TRANSFER_REGISTER_EVENT (CONTRACT, SENDER. RECIEVER) 
    
     */

    //While this works doing isolated events, it is a much better practice to do it using interfaces
    //Literally works similar to java and js and tsx and hard-typed languages
    /*
        event Transfer(

            address indexed from,
            address indexed to,
            uint256 indexed tokenId
        );
    */

   using SafeMath for uint256;
   using Counters for Counters.Counter;

   mapping(uint256=>address) private _tokenOwner;
   mapping(address=>Counters.Counter) private _ownedTokens;
   mapping(uint256=>address) private _ApprovedTokens;


   /**
     * with keccak256 we basically encrypting important functions
     * check moar here:
     * https://ethereum.stackexchange.com/questions/11572/how-does-the-keccak256-hash-function-work
     * https://keccak.team/keccak_specs_summary.html
     */

    constructor() {
        _registerInterface(bytes4(keccak256('balanceOf(bytes4)')^
        keccak256('ownerOf(bytes4)')^
        keccak256('transferFrom(bytes4)')));
    }

    function balanceOf(address _owner) public override view returns (uint256){
        require(_owner != address(0), 'addy is zero');
        return _ownedTokens[_owner].current();
    }

    function ownerOf(uint256 _tokenId) public override view returns(address){
        address owner= _tokenOwner[_tokenId];
        require(owner!=address(0), 'addy is zero');
        return owner;
    }
    
    function _exist(uint256 tokenId) internal view returns(bool){
        address owner= _tokenOwner[tokenId];
        return owner!= address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        //we yet again dont want to do business with zero wallet lmeow
        require(to!=address(0), 'ERC721 minting to addy zero');

        //TokenId shouldnt exist before mint
        require(!_exist(tokenId), 'ERC721 already exist');

        //pointer to owner
        _tokenOwner[tokenId]=to;
        //token amount
        _ownedTokens[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        address owner= ownerOf(tokenId);
        require(to!= owner, 'Error - approval to existing owner');
        require(msg.sender==owner, 'Sender must be owner');
        _approvedTokens[tokenId]=to;

        emit Approval(owner, to, tokenId);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool){
        //We want to check if token exist before verifying owner, much better logic me thinsk
        require(_exist(tokenId), 'Token does not exist!');
        address owner = ownerOf(tokenId);
        return (spender==owner);
    }

    /*
    
        We could use _safeTransferFrom which checks if the receiver is allowed to have ERC721 
        or if address is not (0), but we wont do this cause we like scarcity and
        anons burning tokens

        it's not a bug, its a feature...
     */

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal{
        require(ownerOf(_tokenId)==_from, 'Trying transfer of token that is not own');
        _ownedTokens[_from].decrement();
        _ownedTokens[_to].increment();
        _tokenOwner[_tokenId]=_to;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) override public{
        require(isApprovedOrOwner(msg.sender, tokenId));
        _transferFrom(from, to, tokenId);
    }
}


interface IERC721Metadata {
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol); 
}


contract ERC721Metadata is ERC165, IERC721Metadata {
    string private _name;
    string private _symbol;

    constructor(string memory named, string momory symbolified) {
        _registerInterface(bytes4(keccak256('name(bytes4)')^
        keccak256('symbol(bytes4)')));

        _name=named;
        _symbol=symbolified;
    }

    function name() external view returns(string memory){
        return _name;
    }

    function symbol() external view returns(string memory){
        return _symbol;
    }
}


interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint _index) external view returns(uint256);
}

contract ERC721Enumerable is ERC721, IERC721Enumerable {
    uint256[] private _allTokens;

    mapping(uint256=>uint256) private _allTokenIndex;
    mapping(address=>uint256[]) private _ownedTokens;
    mapping(uint256=>uint256) private _ownedTokenIndex;

    constructor() {
        _registerInterface(bytes4(keccak256('tokenByIndex(bytes4)')^
        keccak256('tokenOfOwnerByIndex(bytes4)')^
        keccak256('totalSupply(bytes4)')));
    }

    function _mint(address to, uint256 tokenId) internal override(ERC721){
        super._mint(to, tokenId);
        _addTokensToOwnerEnumeration(to, tokenId);
        _addTokensToAllTokenEnumeration(tokenId);
    }

    functions _addTokensToAllTokenEnumeration(uint256 tokenId) private{ 
        _allTokenindex[tokenId]=_allTokens.length;
        _allTokens.push(tokenId);
    }

    function _addtokensToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedtokenIndex[tokenId]= _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function tokenByIndex(uint256 index) public override view returns(uint256) {
        require(index<totalSupply(), 'Global index out of balances');
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public override view returns(uint256){
        require(index<balanceOf(owner), 'Owner index out of bounds');
        return _ownedTokens[owner][index];
    }

    function totalSupply() public override view returns(uint256){
        return _allTokens.length;
    }
}

contract ERC721Connector is ERC721Metadata, ERC721Enumerable {
    constructor(string memory name, string memory symbol) ERC721Metadata(name, symbol){}
}


contract Vassago is ERC721Connector {
    string[] public NFT;

    mapping(string=>bool) _NFTExist;

    function mint(string memory _vassago) public {
        require(!_NFTExistÑ_vassago], 'token already exists');

        NFT.push(_vassago);
        uint _id = NFT.length-1;

        _mint(msg.sender, _id);
        _NFTExist[_vassago]=true;

        //Constructor ask for name and symbol

        constructor() ERC721Connector('Vassago', 'VSGO'){}
    }
}