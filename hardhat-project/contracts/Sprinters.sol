// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract Sprinters is ERC721Enumerable, Ownable {

    string _baseTokenURI;

    uint256 public _price = 0.0001 ether;
    uint public maxtokens = 20;

    uint256 public tokenIds; //Used to create specific NFTS?

    bool public _paused;


    IWhitelist whitelist;
    bool public preSaleStarted;
    uint256 public preSaleEnded;

    //modifier -> checks that no transaction happens when the sale is paused
    modifier onlyWhenNotPaused{
        require(!_paused, "The sale is currently paused, please come back later");
        _;
    }

    // constructor -> whitelistContract create, set BaseURI 
    constructor (string memory baseURI, address whitelistContract) ERC721("Sprinters", "SGV"){
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    // when presale starts -> start and set end time 
    function startPresale() public onlyOwner{
        preSaleStarted = true;
        preSaleEnded = block.timestamp + 5 minutes;
    }

    // buy in presale -> check if you are whitelisted 
    function preSaleMint() public payable onlyWhenNotPaused{
        require(preSaleStarted && block.timestamp < preSaleEnded, "Presale is not live");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxtokens, "All tokens exhausted"); 
        require(msg.value >= _price, "Ether sent is not correct");

        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    //buy in sale  
    function mint() public payable onlyWhenNotPaused{
        require(preSaleStarted && block.timestamp >= preSaleEnded, "Presale has not ended yet");
        require(tokenIds < maxtokens, "All tokens exhausted"); 
        require(msg.value >= _price, "Ether sent is not correct");

        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    //baseURI form @openzeppelin
    function _baseURI() internal view virtual override returns (string memory){
        return _baseTokenURI;
    }

    //setpaused
    function setPaused (bool val) public onlyOwner{
        _paused = val;
    }

    //withdraw
    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value:amount}("");
        require(sent, "Failed to send ether");
    }

    receive() external payable {}

    fallback() external payable {}
}