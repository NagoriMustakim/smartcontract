// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

contract boxv2 {
    uint256 public val;

    function inc(uint256 _val) public {
        val += _val;
        
    }
}