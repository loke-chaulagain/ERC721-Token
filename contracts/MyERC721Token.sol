// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721Token is ERC721, ERC721Enumerable, Pausable, Ownable {
    //pausable will allow to pause the contract and people cannot mint
    //enumerable helps to track how many NFT/ERC721 Token have been minted so far so that we can limit the supply
    using Counters for Counters.Counter;
    uint256 maxSupplyLimit = 3;

    bool public isPublicMintOpen = false;
    bool public isVipMintOpen = false;

    mapping(address => bool) public vipList;

    Counters.Counter private _tokenIdCounter;

    //MyERC721Token is contract name and LOKI721 is Token symbol
    constructor() ERC721("MyERC721Token", "LOKI721") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //owner can edit the open close status
    function editMintWindows(bool _isPublicMintOpen, bool _isVipMintOpen)
        external
        onlyOwner
    {
        isPublicMintOpen = _isPublicMintOpen;
        isVipMintOpen = _isVipMintOpen;
    }

    //public can mint our token/nft
    function publicMint() public payable {
        require(isPublicMintOpen, "Public mint is closed right now !!!");
        //payable means this function is now allowed to accept payment

        //how much payment we want from user to mint 1  Token
        //This is basically how much our NFT cost
        //msg.value is the amount send by user from metamask account to the contract
        require(
            msg.value == 0.01 ether,
            "Please send exact amount i.e, 0.01 ether !!!"
        );
        //if this is false the further exection will not be proceed

        //limiting the supply
        require(
            totalSupply() < maxSupplyLimit,
            "Limit has been reached you cannot mint more than maxSupply !!!"
        );

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId); //msg.sender is the who mint the token //actually msg.sender is the metamask address we directly get it
    }

    function vipMint() public payable {
        require(vipList[msg.sender], "You are not a Vip member");
        require(isVipMintOpen, "Vip mint is closed right now !!!");
        require(
            msg.value == 0.001 ether,
            "Please send exact amount i.e, 0.001 ether !!!"
        );
        require(
            totalSupply() < maxSupplyLimit,
            "Limit has been reached you cannot mint more than maxSupply !!!"
        );
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function setVipList(address[] calldata vipAddresses) external onlyOwner {
        for (uint256 i = 0; i < vipAddresses.length; i++) {
            vipList[vipAddresses[i]] = true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
