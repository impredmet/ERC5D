//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC4D} from "./libs/ERC4D.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC6551Registry} from "./libs/ERC6551Registry.sol";
import {ERC6551Account} from "./libs/ERC6551Account.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ERC5D
 * @author https://github.com/impredmet
 * @notice Optimized ERC4D with lower fees, Uniswap V3, and fixed tokenURI for NFTs.
 */
contract ERC5D is Ownable, ERC4D {
    string public dataURI;
    bool public launched;
    uint256 public maxWallet;

    constructor(
        string memory name_, // Name for ERC-20 representation
        string memory symbol_, // Symbol for ERC-20 representation
        uint8 decimals_, // Decimals for ERC-20 representation
        uint256 supply721_, // Supply of ERC721s to mint (eg. 10000)
        ERC6551Registry registry_, // Registry for 6551 accounts
        ERC6551Account implementation_, // Implementation for 6551 accounts
        bytes32 salt_ // Salt for 6551 accounts (eg. keccak256("ERC5D"))
    ) ERC4D(name_, symbol_, decimals_) Ownable(_msgSender()) {
        _setERC721TransferExempt(address(this), true);
        _setERC721TransferExempt(_msgSender(), true);

        setup.push(dddd_setup({implementation: implementation_, registry: registry_, salt: salt_}));

        _mintERC20(_msgSender(), supply721_ * units);
        maxWallet = erc20TotalSupply() / 100;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        uint8 seed = uint8(bytes1(keccak256(abi.encodePacked(id))));
        string memory image;
        string memory color;

        if (seed <= 100) {
            image = "1.jpg";
            color = "Pink";
        } else if (seed <= 160) {
            image = "2.jpg";
            color = "Gray";
        } else if (seed <= 210) {
            image = "3.jpg";
            color = "Green";
        } else if (seed <= 240) {
            image = "4.jpg";
            color = "Yellow";
        } else if (seed <= 255) {
            image = "5.jpg";
            color = "Orange";
        }

        string memory jsonPreImage = string.concat(
            string.concat(
                string.concat('{"name": "Test #', Strings.toString(id)),
                '","description":"A collection of 10,000 Replicants on ERC5D: optimized ERC4D with lower fees, Uniswap V3, and fixed tokenURI for NFTs.","external_url":"https://website.com","image":"'
            ),
            string.concat(dataURI, image)
        );
        string memory jsonPostImage = string.concat('","attributes":[{"trait_type":"Color","value":"', color);
        string memory jsonPostTraits = '"}]}';

        return string.concat(
            "data:application/json;utf8,", string.concat(string.concat(jsonPreImage, jsonPostImage), jsonPostTraits)
        );
    }

    function updateURI(string memory uri) external onlyOwner {
        dataURI = uri;
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }

    function upgrade6551Setup(uint256 setupId_, uint256 tokenId_) external {
        if (_msgSender() != _getOwnerOf(tokenId_)) {
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
        if ((_erc721TransferExempt[_msgSender()] || _erc721TransferExempt[from_]) && !launched) {
            return super._transferERC20WithERC721(from_, to_, value_);
        }

        require(launched, "Not launched yet");

        uint256 bal = erc20BalanceOf(to_);
        require(bal + value_ <= maxWallet, "Max wallet limit exceeded");

        return super._transferERC20WithERC721(from_, to_, value_);
    }

    function setSelfERC721TransferExempt(bool state_) public override {
        require(launched, "Not launched yet");
        super.setSelfERC721TransferExempt(state_);
    }

    function removeLimits() external onlyOwner {
        maxWallet = erc20TotalSupply();
    }
}
