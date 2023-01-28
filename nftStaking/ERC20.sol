// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyToken76 is ERC20, Ownable, ERC721Holder {
    IERC721 public nft;
    uint256 public EMMISION_RATE = (50 * 10**decimals()) / 1 days;
    mapping(uint256 => address) public tokenOwner; //token id to owner
    mapping(uint256 => uint256) public tokenStakeAt; // token id to timestamp

    constructor(address _nft) ERC20("MyToken", "MTK") {
        nft = IERC721(_nft);
    }

    function stake(uint256 _tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenOwner[_tokenId] = msg.sender;
        tokenStakeAt[_tokenId] = block.timestamp;
    }

    function calculateToken(uint256 _tokenId) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - tokenStakeAt[_tokenId];
        return EMMISION_RATE * timeElapsed;
    }

    function unStake(uint256 _tokenId) external {
        require(
            tokenOwner[_tokenId] == msg.sender,
            "You are not owner of this NFT"
        );
        _mint(msg.sender, calculateToken(_tokenId));
        nft.transferFrom(address(this), msg.sender, _tokenId);
        delete tokenOwner[_tokenId];
        delete tokenStakeAt[_tokenId];
    }
}
