// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RiceDay is Ownable, ERC721A, ReentrancyGuard {

    //total Supply
    uint256 public constant MAX_SUPPLY = 8866;

    //sale status variables
    bool public publicSaleStatus = true;
    bool public preSaleStatus = false;
    mapping(address => uint8) private _allowList;

    mapping(address => uint8) private _teamList;
    
    string baseURI;
    bool public revealed = true;
    string public notRevealedUri;

    constructor() ERC721A("RiceDay", "RICE", 5, 8866) {} 

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function publicSaleMint(uint8 numberOfTokens) external payable callerIsUser {
        require(publicSaleStatus, "Public sale minting is not active");
        require(
            numberOfTokens + totalSupply() <= MAX_SUPPLY,
            "Purchase would exceed max tokens"
        );
        // require(
        //     riceDayPrice * numberOfTokens <= msg.value,
        //     "Ether value sent is not correct"
        // );
        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance <= 10, "cannot request that many");
        _safeMint(msg.sender, numberOfTokens);
    }

    function allowlistMint(uint8 numberOfTokens) external payable callerIsUser {
        require(preSaleStatus, "Pre-sale minting is not active");
        require(
            numberOfTokens + totalSupply() <= MAX_SUPPLY,
            "Purchase would exceed max tokens"
        );
        uint8 allowedToMint = _allowList[msg.sender];
        require(
            numberOfTokens <= allowedToMint,
            "Exceeded Max Available to Purchase"
        );
        // require(
        //     riceDayPrice * numberOfTokens <= msg.value,
        //     "Ether value sent is not correct"
        // );
        _allowList[msg.sender] = allowedToMint - numberOfTokens;
        _safeMint(msg.sender, numberOfTokens);
    }

    function teamMint(uint8 numberOfTokens) external payable callerIsUser {
        uint8 allowedToMint = _teamList[msg.sender];
        require(
            numberOfTokens <= allowedToMint,
            "Exceeded Max Available to Purchase"
        );
        require(
            numberOfTokens + totalSupply() <= MAX_SUPPLY,
            "Purchase would exceed max tokens"
        );
        _teamList[msg.sender] = allowedToMint - numberOfTokens;
        _safeMint(msg.sender, 1);
    }

    function togglePublicSale(bool sale) public onlyOwner {
        publicSaleStatus = sale;
    }
    function togglePreSale(bool sale) public onlyOwner {
        preSaleStatus = sale;
    }

    function getPublicSale() public view returns (bool) {
        return publicSaleStatus;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }


    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }   

    

  
}
