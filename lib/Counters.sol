//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./SafeMath.sol";

library Counters {
    
    using SafeMathfor uint256;

    struct Counter {
        uint256 _count;
    }

    //This functions can only be called within the contract
    function current(Counter storage counter) internal view returns (uint256){
        return counter._count;
    }


    function increment(Counter storage counter) internal {
        counter._count+=1;
    }
    function decrement(Counter storage counter) internal {
        counter._count=counter._count.sub(1);
    }
}