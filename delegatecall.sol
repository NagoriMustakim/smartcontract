// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Student {
    uint256 public mySum;
    address public studentAddress;

    function addTwoNumbers(
        address calculator,
        uint256 a,
        uint256 b
    ) public returns (uint256) {
        (bool success, bytes memory result) = calculator.delegatecall(
            abi.encodeWithSignature("add(uint256,uint256)", a, b)
        );
        require(success, "The call to calculator contract failed");
        return abi.decode(result, (uint256));
    }
}

contract Calculator {
    uint256 public result;
    address public user;

    function add(uint256 a, uint256 b) public returns (uint256) {
        result = a + b;
        user = msg.sender;
        return result;
    }
}
// but the problem is that even though we are using the storage of Student,
//  the slot numbers are based on the calculator contract and in this case
//  when you assign a value to result in the add function of Calculator.sol,
// you are actually assigning the value to mySum which in the student contract.
