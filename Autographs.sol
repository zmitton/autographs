// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Counters.sol";


contract Autographs is ERC721("Autographs", "ATG"), Ownable{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;

    mapping (bytes32 => bool) public tokenExists;
    mapping (uint => bytes32) public tokenSvgHash;
    mapping (uint => string) public tokenSvg;
    mapping (uint => string) public names;

    mapping (bytes32 => bool) public whitelist;


    string public baseTokenURI;
    function setBaseURI(string calldata newURI) public onlyOwner{
        baseTokenURI = newURI;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }
    event Minted(string svg);

    function addToWhitelist(bytes32 hashedSecret) public onlyOwner{
        whitelist[hashedSecret] = true;
    }
    function addSvg(uint tokenId, string memory svg) public {
        bytes32 svgHash = keccak256(abi.encodePacked(svg));
        require(svgHash == tokenSvgHash[tokenId], string(abi.encodePacked("missmatch hash calculation: ", svgHash)));
        tokenSvg[tokenId] = svg;
    }

    //minting will save the hash but but only log the full SVG. That way I can create a process that adds them later by anyone willing to pay for it
    function mint(bytes32 secret, address to, string memory name, string memory svg) public {
        bytes32 hashedSecret = keccak256(abi.encodePacked(secret));
        require(whitelist[hashedSecret]);
        bytes32 svgHash = keccak256(abi.encodePacked(svg));
        require(tokenExists[svgHash], "identical svg already exists");
        _safeMint(to,  _tokenIdTracker.current());
        whitelist[hashedSecret] = false;
        names[_tokenIdTracker.current()] = name;
        tokenExists[svgHash] = true;
        tokenSvgHash[_tokenIdTracker.current()] = svgHash;
        emit Minted(svg);
        _tokenIdTracker.increment();
    }
}

// minimal testing needed:
    // addTowhitelist
        // create the secret
        // get the hashed secret
        // add it to the whitelist
        //query whitelist for it
        // try to mint random junk data with it
    // make sure it minted
        //query whitelist for it (should be gone)
        //query all the other vars for it
    //try to add the SVG    
        //find it by querying the log from a public endpoint
        //query for full svg (should be null)
        //add svg
        //query for full svg again (should be there)
// added features
    //offer, bid, removeOffer?, removeDid?
    
