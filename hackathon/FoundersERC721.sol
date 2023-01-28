// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract FoundersERC721 is
    Ownable,
    ReentrancyGuard,
    ERC721Enumerable,
    Pausable
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    event TokenCreated(
        uint256 tokenId,
        string name,
        string symbol,
        string description,
        address companyAddress,
        address founder,
        string companyUrl
    );

    event ListingHubUpdated(address oldListingHub, address newListingHub);

    Counters.Counter private s_tokenIds;
    address private s_listingHub;

    // modifier
    modifier onlyFoundersListing() {
        require(
            msg.sender == s_listingHub,
            "FoundersERC721: Not authorized to perform action"
        );
        _;
    }

    struct Company {
        uint256 companyId;
        string name;
        string symbol;
        string description;
        string image;
        address companyAddress;
        string companyUrl;
    }

    mapping(uint256 => Company) public s_companies;

    constructor(address _listingHub) ERC721("People Funds", "PEOPLE") {
        s_listingHub = _listingHub;
    }

    function createToken(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _image,
        address _companyAddress,
        address _founder,
        string memory _companyUrl
    ) external onlyFoundersListing nonReentrant whenNotPaused {
        require(
            balanceOf(_founder) < 1,
            "FoundersERC721: Cannot list more companies"
        );
        Company memory newCompany = Company(
            s_tokenIds.current(),
            _name,
            _symbol,
            _description,
            _image,
            _companyAddress,
            _companyUrl
        );

        s_companies[s_tokenIds.current()] = newCompany;

        _mint(_founder, s_tokenIds.current());

        emit TokenCreated(
            s_tokenIds.current(),
            _name,
            _symbol,
            _description,
            _companyAddress,
            _founder,
            _companyUrl
        );

        s_tokenIds.increment();
    }

    function buildMetadata(
        uint256 _tokenId
    ) public view returns (string memory) {
        Company memory currentCompany = s_companies[_tokenId];
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                currentCompany.name,
                                '", "description":"',
                                currentCompany.description,
                                '", "image": "',
                                currentCompany.image,
                                '", "attributes":[{"trait_type":"company address","value":"',
                                abi.encodePacked(currentCompany.companyAddress),
                                '"},{"trait_type":"founder","value":"',
                                abi.encodePacked(currentCompany.companyAddress),
                                '"}]}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return buildMetadata(_tokenId);
    }

    function updateListingHub(address _lisingHub) external onlyOwner {
        address oldListingHub = s_listingHub;
        s_listingHub = _lisingHub;

        emit ListingHubUpdated(oldListingHub, _lisingHub);
    }

    function getCompanyAddress(
        uint256 _id
    ) public view returns (address founder) {
        founder = s_companies[_id].companyAddress;
    }

    function getListingHub() public view returns (address listingHub) {
        listingHub = s_listingHub;
    }

    function getCompanyUrl(
        uint256 _id
    ) public view returns (string memory companyUrl) {
        return s_companies[_id].companyUrl;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }
}