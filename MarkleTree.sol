// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract Whitelist {
    bytes32 public merkleRoot;

    constructor(bytes32 _markleRoot) {
        merkleRoot = _markleRoot;
    }

    ///@dev maxAllowanceToMint is veriable which tells number of NFT's a given address can mint.
    function checkInWhitelist(
        bytes32[] calldata proof,
        uint64 maxAllowanceToMint
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encode(msg.sender, maxAllowanceToMint));

        bool verified = MerkleProof.verify(proof, merkleRoot, leaf);
        return verified;
    }
}
