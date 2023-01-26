// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Mynft is ERC721, Ownable {
    uint256 public totalSupply;
    constructor() ERC721("Mynft", "MNFT") {}

    function safeMint() public  {
        totalSupply++;
        _safeMint(msg.sender, totalSupply);

    }
}