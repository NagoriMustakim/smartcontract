// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {FoundersERC721} from "./FoundersERC721.sol";
import {InvestorsERC1155} from "./InvestorsERC1155.sol";

contract ListingHub is ReentrancyGuard, Ownable, Pausable {
    FoundersERC721 public s_foundersERC721;
    InvestorsERC1155 public s_investorsERC115;

    constructor() {}

    function listCompany(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _image,
        string memory _companyUrl,
        string memory _tokenUri,
        uint256 _maxSupply,
        uint256 _fundsToRaise,
        uint256 _holdLimit
    ) external {
        s_foundersERC721.createToken(
            _name,
            _symbol,
            _description,
            _image,
            msg.sender,
            msg.sender,
            _companyUrl
        );

        s_investorsERC115.createShare(
            _tokenUri,
            msg.sender,
            _maxSupply,
            _fundsToRaise,
            _holdLimit
        );
    }

    function updateFoundersERC721(FoundersERC721 _foundersERC721)
        external
        onlyOwner
    {
        s_foundersERC721 = _foundersERC721;
    }

    function updateInvestorsERC1155(InvestorsERC1155 _investorsERC1155)
        external
        onlyOwner
    {
        s_investorsERC115 = _investorsERC1155;
    }
}
