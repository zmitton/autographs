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

    mapping (address => bool) public whitelist;

    constructor(){
        whitelist[0x888AFb5c92776f78ffCB6bfC911D13B644c6a788] = true;
        whitelist[0x7BF7dC710CbBF6c746cFfbC94cACD079E6b42A98] = true;
        whitelist[0x0655885d0b1fCB2c82074A799366B0BAc641eF82] = true;
    }

    string public baseTokenURI;
    function setBaseURI(string calldata newURI) public onlyOwner{
        baseTokenURI = newURI;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }
    event Minted(string svg);

    function addToWhitelist(address hashedSecret) public onlyOwner{
        whitelist[hashedSecret] = true;
    }
    function addSvg(uint tokenId, string memory svg) public {
        bytes32 svgHash = keccak256(abi.encodePacked(svg));
        require(svgHash == tokenSvgHash[tokenId], string(abi.encodePacked("missmatch hash calculation: ", svgHash)));
        tokenSvg[tokenId] = svg;
    }

    //minting will save the hash but but only log the full SVG. That way I can create a process that adds them later by anyone willing to pay for it
    function mint(address to, string memory name, string memory svg, uint8 _v, bytes32 _r, bytes32 _s) public {
        bytes32 svgHash = keccak256(abi.encodePacked(svg));
        address signer = ecrecover(svgHash, _v, _r, _s);
        require(whitelist[signer]);
        require(!tokenExists[svgHash], "identical svg already exists");
        _safeMint(to,  _tokenIdTracker.current());
        whitelist[signer] = false;
        names[_tokenIdTracker.current()] = name;
        tokenExists[svgHash] = true;
        tokenSvgHash[_tokenIdTracker.current()] = svgHash;
        emit Minted(svg);
        _tokenIdTracker.increment();
    }



}

contract thing{
    function sha (string calldata svg) pure public returns (bytes32){
        return keccak256(abi.encodePacked(svg));
    }

    function test1() public pure returns(bytes32){
        // string memory x = "";
        return keccak256("");
    }
    mapping(bytes32=>bool) isHash;
    function test3(string calldata svg) public returns(bytes32){
        bytes32 h = keccak256(abi.encodePacked(svg));
        isHash[h] = true;
        emit Svg(svg);
        return keccak256(abi.encodePacked(svg));
    }
    event Svg(string svg);

    string savedSvg;
    function test4(string calldata svg) public{
        savedSvg = svg;
    }
    function test5(string calldata svg) public view returns(bool){
        return isHash[keccak256(abi.encodePacked(svg))];
    }
    function test6(bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
        address signer = ecrecover(_message, _v, _r, _s);
        return signer;
    }
    function test7(bytes32 _message) public pure returns (bytes32) {
        return _message;
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





//deploy the real contract, try to call the mint function from the metamask page. 
//then work on the other proof functions (only from javascript if its not working


// minimal testing needed:
    // signing with the individual "secret"s would be better and prevent mempool attacks
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
    // offer, bid, removeOffer?, removeDid?
// optimize SVG
  // contact codementor with SVG experience (or even author)?
// integrate everything with metamask
// add a little CSS
// get it wokring on GHpages
// craft email
// send
// and then we play the waiting game
// remember to validate asset: 

// https://rinkeby-api.opensea.io/asset/0xf3d9daa40a2590558f01f280b9e669d6cec4ef4c/1/validate





/*
ask
creates mapping(uint=> mapping(address=>uint)) asks
i.e. asks[ID][currentOwner]
change it to zero to delete the ask

buy
payable function
checks that the requested autograph has a non-zero ask coresponding to its current owner
if its greater than zero, it is the legit ask
call the internal _transfer function
you do not need to delete the ask


bid (offer)
payable function


*/

