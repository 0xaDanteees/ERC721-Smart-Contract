//SPDX-LICENSE-IDENTIFIER: UNLICENSED
// https://eips.ethereum.org/EIPS/eip-165 
pragma solidity ^0.8.9;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

contract ERC165 is IERC165 {
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor(){
        _registerInterface(bytes4(keccak256('supportsInterface(bytes4)')));  
    }

    function supportsInterface(bytes4 interfaceID) external view override returns (bool) {
        return _supportedInterfaces[interfaceID];
    }

    function _registerInterface(bytes4 interfaceID) internal {
        //not 0 addy
        requiere(interfaceID!= 0xffffffff, 'Invalid interface request');
        _supportedInterfaces[interfaceID]=true;
    }

}