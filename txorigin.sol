// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Good {
    address public owner;

    constructor() {
        owner = _msg.sender;
    }

    function setOwner(address _newOwner) public {
        require(tx.origin == owner, "Not owner");
        owner = _newOwner;
    }
}

contract Attack {
    Good public good;

    constructor(address _good) {
        good = Good(_good);
    }

    function attack() public {
        good.setOwner(address(this));
    }
}
//thus not to use tx.origin to determine owner use msg.sender insted of tx.origin
