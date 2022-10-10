// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721Token is ERC721, ERC721Enumerable, Pausable, Ownable {
    //pausable is to pause Mint a any instant of time
    //enumerable to track the minted token so we can limit the supply
    using Counters for Counters.Counter;
    uint256 maxSupplyLimit = 3;
    bool public isPublicMintOpen = false;
    bool public isVipMintOpen = false;

    mapping(address => bool) public vipList;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyERC721Token", "LOKI721") {} //LOKI721 is Token symbol

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintOpenCloseStatus(
        bool _isPublicMintOpen,
        bool _isVipMintOpen
    ) external onlyOwner {
        isPublicMintOpen = _isPublicMintOpen;
        isVipMintOpen = _isVipMintOpen;
    }

    // Modifiers
    modifier generalPublic() {
        require(isPublicMintOpen, "Public mint is closed right now !!!");
        require(
            msg.value == 0.01 ether,
            "Please send exact amount i.e, 0.01 ether !!!"
        );
        _;
    }

    modifier onlyVip() {
        require(isVipMintOpen, "Vip mint is closed right now !!!");
        require(vipList[msg.sender], "You are not a Vip member");
        require(
            msg.value == 0.001 ether,
            "Please send exact amount i.e, 0.001 ether !!!"
        );
        _;
    }

    //setVip addresses
    function setVipList(address[] calldata vipAddresses) external onlyOwner {
        for (uint256 i = 0; i < vipAddresses.length; i++) {
            vipList[vipAddresses[i]] = true;
        }
    }

    //utility function for repetative task
    function internalRepetativeTask() internal {
        require(
            totalSupply() < maxSupplyLimit,
            "Limit has been reached you cannot mint more than maxSupply !!!"
        );
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function publicMint() public payable {
        internalRepetativeTask();
    }

    function vipMint() public payable onlyVip {
        internalRepetativeTask();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //withdraw smart contract amount to the address you specified
    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance; //get balance of this contract
        payable(_addr).transfer(balance);
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
