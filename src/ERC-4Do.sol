//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC4D} from "./libs/ERC4D.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC6551Registry} from "./libs/ERC6551Registry.sol";
import {ERC6551Account} from "./libs/ERC6551Account.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ERC-4Do
 * @author https://github.com/impredmet
 * @notice Optimized ERC-4D Launch with Uniswap V3 and Lower Fees.
 */
contract ERC4Do is Ownable, ERC4D {
    address uniswapV3Router = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address uniswapV3Router02 = address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);

    string public baseURI;
    bool public launched;
    uint256 public maxWallet;

    constructor(
        string memory name_, // Name for ERC-20 representation
        string memory symbol_, // Symbol for ERC-20 representation
        uint8 decimals_, // Decimals for ERC-20 representation
        uint256 supply721_, // Supply of ERC721s to mint
        ERC6551Registry registry_, // Registry for 6551 accounts
        ERC6551Account implementation_, // Implementation for 6551 accounts
        bytes32 salt_ // Salt for 6551 accounts
    ) ERC4D(name_, symbol_, decimals_) Ownable(msg.sender) {
        _setERC721TransferExempt(uniswapV3Router, true);
        _setERC721TransferExempt(uniswapV3Router02, true);
        _setERC721TransferExempt(address(this), true);

        setup.push(dddd_setup({implementation: implementation_, registry: registry_, salt: salt_}));

        uint256 supply = supply721_ * units;
        _mintERC20(msg.sender, supply);
        maxWallet = supply / 100;
    }

    function tokenURI(uint256 id_) public view override returns (string memory) {
        return string.concat(baseURI, Strings.toString(id_));
    }

    function updateURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }

    function upgrade6551Setup(uint256 setupId_, uint256 tokenId_) external {
        if (msg.sender != _getOwnerOf(tokenId_)) {
            revert Unauthorized();
        }
        require(setupId_ < setup.length, "Invalid setup");
        nft_setup_set[tokenId_] = setupId_;
        _createAccount(setupId_, tokenId_);
    }

    function launch() external onlyOwner {
        launched = true;
    }

    function _transferERC20WithERC721(address from_, address to_, uint256 value_) internal override returns (bool) {
        if (!launched) {
            _setERC721TransferExempt(to_, true);
        }

        uint256 bal = erc20BalanceOf(to_);
        require(bal + value_ <= maxWallet, "Too many tokens");

        return super._transferERC20WithERC721(from_, to_, value_);
    }

    function removeLimits() external onlyOwner {
        maxWallet = erc20TotalSupply();
    }
}
