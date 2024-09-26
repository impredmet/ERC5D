pragma solidity ^0.8.26;
// SPDX-License-Identifier: MIT

interface IERC6551Account {
    receive() external payable;

    function token() external view returns (uint256 chainId, address tokenContract, uint256 tokenId);

    function state() external view returns (uint256);

    function isValidSigner(address signer, bytes calldata context) external view returns (bytes4 magicValue);
}