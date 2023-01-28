// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {FoundersERC721} from "./FoundersERC721.sol";

contract InvestorsERC1155 is ERC1155, Ownable, Pausable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    address private s_listingHub;
    Counters.Counter private s_shareIds;
    FoundersERC721 public s_foundersERC721;

    mapping(uint256 => mapping(address => uint256)) public s_investmentCount;

    struct Share {
        uint256 shareId;
        uint256 companyId;
        uint256 totalSupply;
        uint256 maxSupply;
        uint256 fundsToRaise;
        uint256 totalFundsRaised;
        uint256 holdLimit;
    }

    mapping(uint256 => string) public s_tokenUris;
    mapping(uint256 => Share) public s_shares;
    mapping(uint256 => Share) public s_sharesToComanyId;

    modifier onlyListingHub() {
        require(
            msg.sender == s_listingHub,
            "InvestorsERC1155: Not authorized to execute this function"
        );
        _;
    }

    constructor(
        address _listingHub,
        FoundersERC721 _foundersERC721
    ) ERC1155("") {
        s_listingHub = _listingHub;
        s_foundersERC721 = _foundersERC721;
    }

    function createShare(
        string memory _tokenUri,
        address _founder,
        uint256 _maxSupply,
        uint256 _fundsToRaise,
        uint256 _holdLimit
    ) external whenNotPaused nonReentrant {
        Share memory newShare = Share(
            s_shareIds.current(),
            s_foundersERC721.tokenOfOwnerByIndex(_founder, 0),
            0,
            _maxSupply,
            _fundsToRaise,
            0,
            _holdLimit
        );

        s_shares[s_shareIds.current()] = newShare;
        s_sharesToComanyId[
            s_foundersERC721.tokenOfOwnerByIndex(_founder, 0)
        ] = newShare;
        s_tokenUris[s_shareIds.current()] = _tokenUri;
        _mint(address(this), s_shareIds.current(), _maxSupply, "");
        s_shareIds.increment();
    }

    function invest(
        uint256 _companyId,
        uint256 amount
    ) external payable nonReentrant {
        Share memory tempShare = s_sharesToComanyId[_companyId];
        uint256 shareId = tempShare.shareId;

        Share memory currentShare = s_shares[shareId];

        require(
            currentShare.fundsToRaise >= currentShare.totalFundsRaised,
            "InvestorsERC1155: You cannot invest already satisfied"
        );

        require(
            s_investmentCount[shareId][msg.sender].add(amount) <=
                currentShare.holdLimit,
            "InvestorsERC1155: You cannot invest more amount"
        );

        uint256 price = getPrice(shareId);
        uint256 payableAmount = price.mul(amount);

        require(
            msg.value == payableAmount,
            "InvestorsERC1155: Not enough funds to buy"
        );

        require(
            currentShare.totalSupply + amount <= currentShare.maxSupply,
            "InvestorsERC1155: Funds are full cannot buy"
        );

        currentShare.totalFundsRaised =
            currentShare.totalFundsRaised +
            payableAmount;

        currentShare.totalSupply = currentShare.totalSupply + amount;

        address companyAddress = s_foundersERC721.getCompanyAddress(_companyId);

        payable(companyAddress).transfer(payableAmount);

        safeTransferFrom(address(this), msg.sender, shareId, amount, "");
    }

    function getMaxSupply(uint256 _id) public view returns (uint256 maxSupply) {
        Share memory tempShare = s_sharesToComanyId[_id];
        uint256 shareId = tempShare.shareId;

        Share memory currentShare = s_shares[shareId];

        maxSupply = currentShare.maxSupply;
    }

    function getTotalSupply(
        uint256 _id
    ) public view returns (uint256 totalSupply) {
        Share memory tempShare = s_sharesToComanyId[_id];
        uint256 shareId = tempShare.shareId;

        Share memory currentShare = s_shares[shareId];

        totalSupply = currentShare.totalSupply;
    }

    function getFundsToRaise(
        uint256 _id
    ) public view returns (uint256 fundsToRaise) {
        Share memory tempShare = s_sharesToComanyId[_id];
        uint256 shareId = tempShare.shareId;

        Share memory currentShare = s_shares[shareId];

        fundsToRaise = currentShare.fundsToRaise;
    }

    function getTotalRaised(
        uint256 _id
    ) public view returns (uint256 totalRaised) {
        Share memory tempShare = s_sharesToComanyId[_id];
        uint256 shareId = tempShare.shareId;

        Share memory currentShare = s_shares[shareId];

        totalRaised = currentShare.totalFundsRaised;
    }

    function getPrice(uint256 _id) public view returns (uint256 price) {
        uint256 maxSupply = s_shares[_id].maxSupply;
        uint256 fundsToRaise = s_shares[_id].fundsToRaise;

        return maxSupply.div(fundsToRaise);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return s_tokenUris[_id];
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    function getListingHub() public view returns (address _listingHub) {
        _listingHub = s_listingHub;
    }
}