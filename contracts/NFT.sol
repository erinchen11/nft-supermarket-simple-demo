//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
// ERC721 NFT functionality
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

/*
tokenId: track token
contractAddress: can allow marketplace to interact with NFT
function mintToken:
user mint the tokenURI of NFT into Token of NFT-marketplace
and also allow marketplace can transact with user.
 */
contract NFT is ERC721URIStorage {
    // use counter to track token
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // address of market
    address contractAddress;
    // constructor set up address of marketplace, and token's name, symbol
    constructor(address marketplaceAddress) ERC721('NFTSuper', 'NFTS') {
        // set contractAddress to marketplaceAddress
        contractAddress = marketplaceAddress;
    }

    /*
    mintToken:
    use it to mint the Item into Token by using tokenURI, 
    will return the id of the new Token
     */

    function mintToken(string memory tokenURI) public returns(uint) {
         // remember to track token
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        // set the token URI: id and url
        _setTokenURI(newItemId, tokenURI);
        // use setApprovalForAll to allow marketplace to tranact with users.
        setApprovalForAll(contractAddress, true);
        // mint the token and set it for sale then return the id
        return newItemId;
    }
}