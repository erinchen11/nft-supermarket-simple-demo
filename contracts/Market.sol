//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// prevent reentrancy attack
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Market is ReentrancyGuard {
    using Counters for Counters.Counter;

    // track token and token's state

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;

    // determine who is the owner of the contract
    // charge a listing fee so the owner makes a commission

    // detemine who is the owner of contract
    address payable owner;
    // user have to charge listing fee when mint token
    uint256 listingPrice = 0.045 ether;

    // start to construct
    constructor() {
        // set the owner
        owner = payable(msg.sender);
    }

    // token's struct, token's name: MarketToken
    struct MarketToken {
        uint256 itemId;
        address nftContract; // need to call nft contract to mint token, because function mintToken
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // tokenId return token
    mapping(uint256 => MarketToken) private idToMarketToken;

    // event on web been listen - what item has been minted
    // and log the info. : itemId, nftContract, tokenId
    event MarketTokenMinted(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // get the listing price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // user can call this function to create a market item for sale
    // argument: tokenId, nftContract, price
    // use modifier nonReentrancy to avoid been attacked
    function makeMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least one wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        // update _tokenIds, and assign to itemId
        _tokenIds.increment();
        // itemId track the token
        uint256 itemId = _tokenIds.current();

    // use the itemId to map an MonkeyToken by input argument
        idToMarketToken[itemId] = MarketToken(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(msg.sender),
            //payable(address(0)),
            price,
            false
        );

        // start NFT transaction
        // transfer the NFT token from seller to market contract address.
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketTokenMinted(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            msg.sender,
            //address(0),
            price,
            false
        );
    }

    // user call this function to make a transaction of item with other user
    // argument: nftContract, itemId (it track the item which is sell)
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        // keep track the token id and price
        uint256 tokenId = idToMarketToken[itemId].tokenId;
        uint256 price = idToMarketToken[itemId].price;

        require(
            msg.value == price,
            "Please charge the price to continue"
        );

        // transfer the amount to the seller
        idToMarketToken[itemId].seller.transfer(msg.value);
        // transfer the token from contract address to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        // change other attributes of token
        idToMarketToken[itemId].owner = payable(msg.sender);
        idToMarketToken[itemId].sold = true;
        //update the token which track already sold - _tokenSold

        _tokensSold.increment();

        payable(owner).transfer(listingPrice);
    }

     // function to return number of unsold items, use array to store (will be many items)

    function fetchMarketTokens() public view returns (MarketToken[] memory) {
        // need  variables to change state of contract
        // the count of created items,  the count of unsold items, track index for array
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _tokensSold.current();
        uint256 currentIndex = 0;
        MarketToken[] memory items = new MarketToken[](unsoldItemCount);
        
        // loop over created items
        for (uint256 i = 0; i < itemCount; i++) {
            // if the item is unsold, push it into unsoldItems
            // if (idToMonkeyToken[i + 1].owner == msg.sender) {
            if (idToMarketToken[i + 1].owner == address(0)) {
                 // index of unsoldItems
                uint256 currentId = i + 1;
                // get the unsoldItem to assign currentItem
                MarketToken storage currentItem = idToMarketToken[currentId];
                // put the unsoldItem into array
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // return NFT tokens that user has purchase, use array to store
    function fetchMyNFTs() public view returns (MarketToken[] memory) {
        // need  variables to change state of contract
        // the  count of total items,  track item that user has ,
        // use array to record user's items, track index for array of user's items
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        // find the item which user's in total items.
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        // record user's items
        MarketToken[] memory items = new MarketToken[](itemCount);
        // get all the items which user has.
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                uint256 currentId = idToMarketToken[i + 1].itemId;
                // get the current item in idToMarketToken
                MarketToken storage currentItem = idToMarketToken[currentId];
                // put it into item array
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // return the NFT token which user already minted
    // similiar to FetchMyNFTs(), change owner to seller
    function fetchItemsCreated() public view returns (MarketToken[] memory) {
         // need  variables to change state of contract
        // the  count of total items,  track item that user has ,
        // use array to record user's items, track index for array of user's items
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketToken[] memory items = new MarketToken[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].seller == msg.sender) {
                uint256 currentId = idToMarketToken[i + 1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
