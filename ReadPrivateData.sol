// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Login {
    // Private variables
    // Each bytes32 variable would occupy one slot
    // because bytes32 variable has 256 bits(32*8)
    // which is the size of one slot

    // Slot 0
    bytes32 private username;
    // Slot 1
    bytes32 private password;
    // Slot 2
    uint256 private number;

    constructor(
        bytes32 _username,
        bytes32 _password,
        uint256 _number
    ) {
        username = _username;
        password = _password;
        number = _number;
    }
}
