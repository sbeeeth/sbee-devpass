// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}
struct tokenData {
    uint256 erc20Balance;
    bool unlocked;
    string data;
}

contract MyToken is ERC721, ERC721Burnable, Ownable, ReentrancyGuard {
    uint256 private currentId;
    mapping(uint256 => tokenData) public tokensData;
    IERC20 erc20Token;
    constructor(
        address initialOwner
    ) ERC721("MyToken", "MTK") Ownable(initialOwner) {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function mint(address erc721Recipient) external onlyOwner nonReentrant {
        _mint(erc721Recipient, currentId++);
    }

    function lockTokens(
        uint256 erc20TokenAmount,
        uint256 tokenId
    ) external onlyOwner {
        if (erc20TokenAmount > 0) {
            erc20Token.transferFrom(
                msg.sender,
                address(this),
                erc20TokenAmount
            );
        }
        tokensData[tokenId].erc20Balance = erc20TokenAmount;
    }

    function changeERC20Address(address newERC20Address) external onlyOwner {
        erc20Token = IERC20(newERC20Address);
    }

    function unlockERC20Tokens(uint256 tokenId) external nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "NOT_OWNER");
        require(tokensData[tokenId].unlocked, "LOCKED");
        erc20Token.transferFrom(
            address(this),
            msg.sender,
            tokensData[tokenId].erc20Balance
        );
        tokensData[tokenId].erc20Balance = 0;
    }

    function adminUnlock(
        uint256 tokenId,
        string memory data
    ) external onlyOwner {
        tokensData[tokenId].unlocked = true;
        tokensData[tokenId].data = data;
    }
}
