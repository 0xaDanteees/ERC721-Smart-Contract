//SPDX-License-Identifier: UNLICENSED


/**
 * https://www.youtube.com/watch?v=ij7drxnO0l8
 * https://azvect.medium.com/part-5-evm-bytecode-security-512c4d18d6a3
 * https://docs.openzeppelin.com/contracts/2.x/api/math
 * 
 */

pragma solidity ^0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns(uint256){
        uint256 r= a+b;
        require(r>=a, "SafeMath addition overflow");
        return r;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256){
        require(b<=a, "safeMath: substraction underflow");
    uint256 r= a-b;
    return r;

    }

    function mul(uint256 a, uint256 b) internal pure returns(uint256){
        if(a==0){
            return 0;
        }
        uint256 r=a*b;
        require(r/a==b, "SafeMath multiplication overflow");
        return r;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256){
        require(b>0, "SafeMath divition by zero");
        uint256 r = a/b;
        return r;
    }

    function mod(uint256 a , uint256 b) internal pure returns(uint256){
        require(b!=0, "SafeMath mod by zero");
        return a%b;
    }
}

/*
 * Explanation of Gas Optimization:
    mul() and div(): 
  
    have extra checks to ensure everything runs smoothly. These checks may make 
    the code use a bit more gas , but they're essential to keep everything safe and secure.
 */